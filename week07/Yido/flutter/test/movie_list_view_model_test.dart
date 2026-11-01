import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';

import 'support/fake_tmdb_movie_service.dart';

void main() {
  test('인기 영화는 앞의 5개만, 적으면 있는 만큼만 쓴다', () async {
    final many = MovieHomeViewModel(
      FakeTmdbMovieService(
        popular: [for (var i = 1; i <= 20; i++) fakeMovie(i)],
      ),
    );
    await many.loadPopular();
    expect(many.popularMovies.map((m) => m.id), [1, 2, 3, 4, 5]);

    final few = MovieHomeViewModel(
      FakeTmdbMovieService(popular: [fakeMovie(1), fakeMovie(2)]),
    );
    await few.loadPopular();
    expect(few.popularMovies.length, 2);
    expect(few.status, MovieHomeLoadStatus.success);
  });

  test('Discover를 page 1부터 불러 중복 없이 최대 30개를 만든다', () async {
    final service = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [for (var i = 1; i <= 20; i++) fakeMovie(i)],
          // 2페이지에 1페이지와 겹치는 영화가 섞여 있다
          [for (var i = 15; i <= 34; i++) fakeMovie(i)],
          [for (var i = 35; i <= 54; i++) fakeMovie(i)],
        ],
      },
    );
    final viewModel = MovieListViewModel(service);
    await viewModel.loadInitial();

    expect(viewModel.status, MovieListLoadStatus.success);
    expect(viewModel.movies.length, 30);
    expect(viewModel.movies.map((m) => m.id).toSet().length, 30);
    expect(service.discoverCalls.map((c) => c.page), [1, 2]);
    expect(viewModel.genres.length, 2);
  });

  test('장르 선택은 with_genres로 page 1부터 다시 요청하고, 전체는 보내지 않는다', () async {
    final service = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [fakeMovie(1)],
        ],
        878: [
          [fakeMovie(2), fakeMovie(3)],
        ],
      },
    );
    final viewModel = MovieListViewModel(service);
    await viewModel.loadInitial();
    await viewModel.selectGenre(878);

    expect(service.discoverCalls.last, (page: 1, genreId: 878));
    expect(viewModel.movies.map((m) => m.id), [2, 3]);

    await viewModel.selectGenre(null);
    expect(service.discoverCalls.last, (page: 1, genreId: null));
    expect(viewModel.movies.map((m) => m.id), [1]);
  });

  test('결과가 없으면 Empty, 실패하면 Error 후 다시 시도로 Success', () async {
    final service = FakeTmdbMovieService(discoverPages: {}, fail: true);
    final viewModel = MovieListViewModel(service);

    await viewModel.loadInitial();
    expect(viewModel.status, MovieListLoadStatus.error);

    service.fail = false;
    await viewModel.retry();
    expect(viewModel.status, MovieListLoadStatus.empty);
  });

  test('요청 중에는 장르를 바꾸지 못한다', () async {
    final service = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [fakeMovie(1)],
        ],
      },
    );
    final viewModel = MovieListViewModel(service);
    final loading = viewModel.loadInitial();
    expect(viewModel.isLoading, isTrue);

    await viewModel.selectGenre(878);
    expect(viewModel.selectedGenreId, isNull);
    await loading;
    expect(service.discoverCalls.where((c) => c.genreId == 878), isEmpty);
  });
}
