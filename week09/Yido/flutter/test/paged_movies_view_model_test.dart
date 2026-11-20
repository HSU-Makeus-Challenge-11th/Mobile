import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';

import 'support/fake_tmdb_movie_service.dart';

void main() {
  late FakeTmdbMovieService tmdb;
  late PagedMoviesViewModel vm;

  setUp(() {
    tmdb = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [fakeMovie(1), fakeMovie(2)],
          [fakeMovie(2), fakeMovie(3)], // 2는 앞 page와 겹친다
          [fakeMovie(4)],
        ],
        18: [
          [fakeMovie(10, title: '드라마')],
        ],
      },
    );
    vm = PagedMoviesViewModel(tmdbApi: tmdb);
  });

  List<int> ids() => vm.movies.map((movie) => movie.id).toList();

  test('first page only, then more pages append without duplicates', () async {
    await vm.loadInitial();
    expect(vm.phase, LoadPhase.ready);
    expect(ids(), [1, 2]);
    expect(tmdb.discoverCalls.map((call) => call.page), [1]);

    await vm.loadNextPage();
    expect(ids(), [1, 2, 3]);
    expect(vm.nextPage, 3);
    expect(vm.hasMore, isTrue);

    await vm.loadNextPage();
    expect(ids(), [1, 2, 3, 4]);
    expect(vm.hasMore, isFalse);
    await vm.loadNextPage(); // 마지막 page 뒤에는 요청하지 않는다
    expect(tmdb.discoverCalls, hasLength(3));
  });

  test('a failed next page keeps the list and retries the same page', () async {
    await vm.loadInitial();
    tmdb.failOncePages.add(2);
    await vm.loadNextPage();
    expect(vm.loadMoreError, '추가 영화 조회에 실패했습니다.');
    expect(ids(), [1, 2]);
    expect(vm.nextPage, 2);

    await vm.loadNextPage();
    expect(tmdb.discoverCalls.map((call) => call.page), [1, 2, 2]);
    expect(vm.loadMoreError, isNull);
    expect(ids(), [1, 2, 3]);
  });

  test('loading more ignores a second tap', () async {
    await vm.loadInitial();
    final gate = Completer<void>();
    tmdb.delay = (page, _, _) => page == 2 ? gate.future : Future.value();
    final pending = vm.loadNextPage();
    expect(vm.isLoadingMore, isTrue);
    await vm.loadNextPage();
    gate.complete();
    await pending;
    expect(tmdb.discoverCalls.where((call) => call.page == 2), hasLength(1));
  });

  test('a late answer for the old genre is ignored', () async {
    final gate = Completer<void>();
    tmdb.delay = (page, genreId, _) =>
        genreId == null ? gate.future : Future.value();
    final oldRequest = vm.loadInitial();
    await vm.loadInitial(genreId: 18);
    expect(ids(), [10]);
    gate.complete();
    await oldRequest;
    expect(ids(), [10]);
    expect(vm.selectedGenreId, 18);
  });

  test('changing the condition clears the more-loading state', () async {
    await vm.loadInitial();
    final gate = Completer<void>();
    tmdb.delay = (page, genreId, _) => page == 2 ? gate.future : Future.value();
    final more = vm.loadNextPage();
    await vm.loadInitial(genreId: 18);
    expect(vm.isLoadingMore, isFalse);
    expect(vm.loadMoreError, isNull);
    gate.complete();
    await more;
    expect(ids(), [10]);
    expect(vm.isLoadingMore, isFalse);
  });

  test('search and empty and error are separate phases', () async {
    tmdb.searchPages['별빛'] = [
      [fakeMovie(550, title: '별빛 아래 우리')],
    ];
    await vm.loadInitial(query: '  별빛 ');
    expect(tmdb.searchCalls.single, (page: 1, query: '별빛'));
    expect(vm.phase, LoadPhase.ready);

    await vm.loadInitial(query: '없는 영화');
    expect(vm.phase, LoadPhase.empty);

    tmdb.fail = true;
    await vm.loadInitial(query: '별빛');
    expect(vm.phase, LoadPhase.error);
    expect(vm.errorMessage, '검색 결과를 불러오지 못했습니다.');
  });

  test('total pages over 500 stop at 500', () async {
    tmdb.delay = null;
    final big = FakeTmdbMovieService(
      discoverPages: {
        null: List.generate(600, (i) => [fakeMovie(i + 1)]),
      },
    );
    final paged = PagedMoviesViewModel(tmdbApi: big);
    await paged.loadInitial();
    expect(paged.totalPages, PagedMoviesViewModel.maxTmdbPage);
  });
}
