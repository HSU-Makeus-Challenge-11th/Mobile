import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';

import 'support/fake_member_services.dart';
import 'support/fake_tmdb_movie_service.dart';

void main() {
  late FakeRatingApiService ratingService;
  late FakeTmdbMovieService movieService;
  late MyRatingsViewModel viewModel;

  setUp(() {
    ratingService = FakeRatingApiService();
    movieService = FakeTmdbMovieService(
      detailMovies: {550: fakeMovie(550, title: '파이트 클럽')},
    );
    viewModel = MyRatingsViewModel(ratingService, movieService, 1);
  });

  test('RatingDto parses a null comment and the date', () {
    final rating = RatingDto.fromJson(const {
      'ratingId': 12,
      'movieId': 550,
      'score': 5,
      'comment': null,
      'createdAt': '2026-09-06T12:14:03.000Z',
      'updatedAt': '2026-09-06T12:14:03.000Z',
    });
    expect(rating.ratingId, 12);
    expect(rating.comment, isNull);
    expect(rating.createdAt, DateTime.utc(2026, 9, 6, 12, 14, 3));
  });

  test('loads memberId 1 and goes through loading to success', () async {
    ratingService.ratings = [fakeRating(1)];
    final future = viewModel.load();
    expect(viewModel.status, MyRatingsLoadStatus.loading);
    await future;
    expect(ratingService.memberCalls, [1]);
    expect(viewModel.status, MyRatingsLoadStatus.success);
    expect(viewModel.ratings.single.movie?.title, '파이트 클럽');
    expect(viewModel.message, isNull);
  });

  test('an empty list is Empty, not Error', () async {
    await viewModel.load();
    expect(viewModel.status, MyRatingsLoadStatus.empty);
  });

  test('400, 404 and network failures have different messages', () async {
    final expected = {
      400: 'memberId 형식을 다시 확인해 주세요.',
      404: '존재하지 않는 회원입니다.',
      0: '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
    };
    for (final MapEntry(key: status, value: message) in expected.entries) {
      ratingService.errorStatus = status;
      await viewModel.load();
      expect(viewModel.status, MyRatingsLoadStatus.error);
      expect(viewModel.message, message);
    }
  });

  test('a TMDB 404 keeps the rating and the movie stays null', () async {
    ratingService.ratings = [fakeRating(1, movieId: 13, comment: null)];
    await viewModel.load();
    expect(viewModel.status, MyRatingsLoadStatus.success);
    expect(viewModel.ratings.single.movie, isNull);
    expect(viewModel.message, contains('일부 영화 정보'));
  });

  test(
    'a TMDB network failure keeps ratings and is retried next time',
    () async {
      ratingService.ratings = [fakeRating(1)];
      movieService.failingDetailIds.add(550);
      await viewModel.load();
      expect(viewModel.status, MyRatingsLoadStatus.success);
      expect(viewModel.ratings.single.movie, isNull);

      movieService.failingDetailIds.clear();
      await viewModel.load();
      expect(viewModel.ratings.single.movie?.title, '파이트 클럽');
    },
  );

  test('the same movieId is requested once', () async {
    ratingService.ratings = [fakeRating(1), fakeRating(2), fakeRating(3)];
    await viewModel.load();
    await viewModel.load();
    expect(movieService.detailCalls, [550]);
  });

  test('an older response is ignored by the request version', () async {
    final gate = ratingService.gate = Completer<void>();
    ratingService.ratings = [fakeRating(1)];
    final first = viewModel.load();
    ratingService.gate = null;
    ratingService.ratings = const [];
    await viewModel.load();
    gate.complete();
    await first;
    expect(viewModel.status, MyRatingsLoadStatus.empty);
    expect(movieService.detailCalls, isEmpty);
  });

  test(
    'debug modes query other members and retry returns to memberId 1',
    () async {
      await viewModel.changeDebugMode(MyRatingsDebugMode.empty);
      await viewModel.changeDebugMode(MyRatingsDebugMode.failure);
      await viewModel.retry();
      expect(ratingService.memberCalls, [3, 999999, 1]);
      expect(viewModel.debugMode, MyRatingsDebugMode.normal);
    },
  );

  group('writes', () {
    setUp(
      () => ratingService.ratings = [fakeRating(1), fakeRating(2, movieId: 13)],
    );

    test('update sends the ids and reloads the list', () async {
      await viewModel.load();
      ratingService.memberCalls.clear();
      await viewModel.updateRating(ratingId: 1, score: 3, comment: '보통');
      expect(ratingService.updated.single, (
        memberId: 1,
        ratingId: 1,
        score: 3,
        comment: '보통',
      ));
      expect(ratingService.memberCalls, [1]);
      expect(viewModel.status, MyRatingsLoadStatus.success);
    });

    test('deleting the last rating shows Empty', () async {
      await viewModel.load();
      ratingService.ratings = const [];
      await viewModel.deleteRating(2);
      expect(ratingService.deleted.single, (memberId: 1, ratingId: 2));
      expect(viewModel.status, MyRatingsLoadStatus.empty);
    });

    test('a failed GET after a write does not fail the write', () async {
      await viewModel.load();
      ratingService.errorStatus = 0;
      await viewModel.updateRating(ratingId: 1, score: 3);
      expect(viewModel.status, MyRatingsLoadStatus.error);
      expect(viewModel.refreshWarning, contains('저장은 완료됐지만'));
      expect(ratingService.updated, hasLength(1));

      // 재시도는 GET만 다시 보내고 PATCH는 다시 보내지 않는다
      ratingService.errorStatus = null;
      await viewModel.retry();
      expect(viewModel.status, MyRatingsLoadStatus.success);
      expect(viewModel.refreshWarning, isNull);
      expect(ratingService.updated, hasLength(1));
    });

    test('403 and 404 reload the list and rethrow', () async {
      await viewModel.load();
      for (final code in ['COMMON403', 'COMMON404']) {
        ratingService.writeError = (
          status: code == 'COMMON403' ? 403 : 404,
          code: code,
          message: '실패',
        );
        ratingService.memberCalls.clear();
        await expectLater(
          viewModel.deleteRating(1),
          throwsA(isA<DioException>()),
        );
        expect(ratingService.memberCalls, [1]);
      }
    });

    test('400 rethrows without reloading', () async {
      await viewModel.load();
      ratingService.memberCalls.clear();
      ratingService.writeError = (
        status: 400,
        code: 'COMMON400',
        message: '실패',
      );
      await expectLater(
        viewModel.updateRating(ratingId: 1, score: 9),
        throwsA(isA<DioException>()),
      );
      expect(ratingService.memberCalls, isEmpty);
    });
  });
}
