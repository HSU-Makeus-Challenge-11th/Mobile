import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/map_bounded.dart';
import 'package:movielog/view_models/favorites_view_model.dart';
import 'package:movielog/view_models/load_phase.dart';

import 'support/fake_favorite_api.dart';
import 'support/fake_tmdb_movie_service.dart';

void main() {
  late FakeFavoriteApi api;
  late FakeTmdbMovieService tmdb;
  late SessionGuard guard;
  late int expired;

  FavoritesViewModel create() => FavoritesViewModel(
    favoriteApi: api,
    tmdbApi: tmdb,
    sessionGuard: guard,
    accountId: 'a@umc.com',
    onSessionExpired: () async => expired++,
  );

  setUp(() {
    api = FakeFavoriteApi();
    tmdb = FakeTmdbMovieService(
      detailMovies: {
        for (var id = 1; id <= 12; id++) id: fakeMovie(id, title: '영화 $id'),
      },
    );
    guard = SessionGuard()..startSession('a@umc.com');
    expired = 0;
  });

  test('mapBounded keeps order and limits concurrency', () async {
    var running = 0;
    var peak = 0;
    final result = await mapBounded(List.generate(12, (i) => i), 5, (
      value,
    ) async {
      running++;
      peak = running > peak ? running : peak;
      await Future<void>.delayed(Duration(milliseconds: 12 - value));
      running--;
      return value * 2;
    });
    expect(result, List.generate(12, (i) => i * 2));
    expect(peak, 5);
  });

  test('favorites are joined with TMDB movies by movieId', () async {
    api.movieIds.addAll([3, 7]);
    final vm = create();
    await vm.refresh();
    expect(vm.phase, LoadPhase.ready);
    expect(vm.items.map((item) => item.movie!.title), ['영화 7', '영화 3']);
    expect(tmdb.detailCalls, unorderedEquals([3, 7]));
  });

  test('empty and error are different states', () async {
    final vm = create();
    await vm.refresh();
    expect(vm.phase, LoadPhase.empty);

    api.listError = DioException(requestOptions: RequestOptions());
    await vm.refresh();
    expect(vm.phase, LoadPhase.error);
    expect(vm.errorMessage, '즐겨찾기를 불러오지 못했습니다.');
  });

  test('one failed movie keeps the other cards and can be retried', () async {
    api.movieIds.addAll([3, 7]);
    tmdb.failingDetailIds.add(3);
    final vm = create();
    await vm.refresh();
    expect(vm.phase, LoadPhase.ready);
    expect(vm.items.where((item) => item.hasMovie), hasLength(1));
    final failed = vm.items.singleWhere((item) => !item.hasMovie);
    expect(failed.favorite.movieId, 3);
    expect(failed.errorMessage, isNotNull);

    tmdb.failingDetailIds.clear();
    tmdb.detailCalls.clear();
    await vm.retryMovie(3);
    expect(tmdb.detailCalls, [3]); // 그 카드만 다시 조회한다
    expect(vm.items.every((item) => item.hasMovie), isTrue);
  });

  test(
    'refresh after removal drops the movie without a loading flash',
    () async {
      api.movieIds.addAll([3, 7]);
      final vm = create();
      await vm.refresh();
      api.movieIds.remove(7);
      api.gate = Completer<void>();
      final pending = vm.refresh();
      expect(vm.phase, LoadPhase.ready); // 기존 카드를 지우지 않는다
      api.gate!.complete();
      await pending;
      expect(vm.items.single.favorite.movieId, 3);
    },
  );

  test('a response from the previous account is not shown', () async {
    api.movieIds.add(3);
    final vm = create();
    api.gate = Completer<void>();
    final pending = vm.refresh();
    guard.invalidate(); // 로그아웃
    guard.startSession('b@umc.com');
    api.gate!.complete();
    await pending;
    expect(vm.items, isEmpty);
    expect(vm.phase, isNot(LoadPhase.ready));
  });

  test('session expiry codes call the expiry handler once', () async {
    api.listError = favoriteError('/v8/favorites', 401, 'AUTH401_2');
    final vm = create();
    await vm.refresh();
    expect(expired, 1);
  });
}
