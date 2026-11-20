import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_member_services.dart';
import 'support/fake_tmdb_movie_service.dart';
import 'support/fake_token_storage.dart';

void main() {
  late FakeRatingApiService ratingService;
  late FakeTmdbMovieService movieService;
  late FakeTokenStorage storage;
  late AuthViewModel auth;
  late SessionRatingStore store;
  late MyRatingsViewModel viewModel;

  setUp(() async {
    ratingService = FakeRatingApiService();
    movieService = FakeTmdbMovieService(
      detailMovies: {550: fakeMovie(550, title: '파이트 클럽')},
    );
    storage = FakeTokenStorage();
    auth = AuthViewModel(FakeAuthApiService(), FakeMemberApiService(), storage);
    await auth.login('a@umc.com', 'Umc1234!');
    store = SessionRatingStore(auth);
    viewModel = MyRatingsViewModel(ratingService, movieService, store, auth);
  });

  void add(RatingDto rating) => store.put(rating, version: store.version);

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

  test('nothing created this session is Empty, not Error', () async {
    await viewModel.load();
    expect(viewModel.status, MyRatingsLoadStatus.empty);
  });

  test('session ratings are joined with TMDB info, newest first', () async {
    add(fakeRating(1));
    add(fakeRating(2, movieId: 13, comment: null));
    await viewModel.load();
    expect(viewModel.status, MyRatingsLoadStatus.success);
    expect(viewModel.ratings.map((e) => e.rating.ratingId), [2, 1]);
    expect(viewModel.ratings.last.movie?.title, '파이트 클럽');
    // TMDB에 없는 영화도 평점은 남기고 제목만 대신 표시한다
    expect(viewModel.ratings.first.movie, isNull);
    expect(viewModel.message, contains('일부 영화 정보'));
  });

  test('a TMDB network failure is retried next time', () async {
    movieService.failingDetailIds.add(550);
    add(fakeRating(1));
    await viewModel.load();
    expect(viewModel.ratings.single.movie, isNull);
    movieService.failingDetailIds.clear();
    await viewModel.load();
    expect(viewModel.ratings.single.movie?.title, '파이트 클럽');
    expect(movieService.detailCalls.last, 550);
  });

  test('update sends no memberId and shows the returned rating', () async {
    add(fakeRating(1));
    await viewModel.load();
    await viewModel.updateRating(ratingId: 1, score: 3, comment: '보통');
    expect(ratingService.updated.single, (
      ratingId: 1,
      score: 3,
      comment: '보통',
    ));
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.ratings.single.rating.score, 3);
  });

  test('deleting the last rating shows Empty', () async {
    add(fakeRating(1));
    await viewModel.load();
    await viewModel.deleteRating(1);
    await Future<void>.delayed(Duration.zero);
    expect(ratingService.deleted, [1]);
    expect(viewModel.status, MyRatingsLoadStatus.empty);
  });

  test('403 keeps the session and the rating, then rethrows', () async {
    add(fakeRating(1));
    ratingService.writeError = (
      status: 403,
      code: 'RATING403_1',
      message: '본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.',
    );
    await expectLater(viewModel.deleteRating(1), throwsA(isA<DioException>()));
    expect(auth.status, AuthStatus.signedIn);
    expect(store.ratings, hasLength(1));
  });

  test('404 removes the gone rating from the session list', () async {
    add(fakeRating(1));
    ratingService.writeError = (
      status: 404,
      code: 'RATING404_1',
      message: '해당 평점을 찾을 수 없습니다.',
    );
    await expectLater(
      viewModel.updateRating(ratingId: 1, score: 2),
      throwsA(isA<DioException>()),
    );
    expect(store.ratings, isEmpty);
  });

  test('an expired token signs out and clears the list', () async {
    add(fakeRating(1));
    ratingService.writeError = (
      status: 401,
      code: 'AUTH401_4',
      message: '토큰이 만료되었습니다. 다시 로그인해주세요.',
    );
    await expectLater(viewModel.deleteRating(1), throwsA(isA<DioException>()));
    expect(auth.status, AuthStatus.signedOut);
    expect(auth.sessionExpired, isTrue);
    expect(store.ratings, isEmpty);
  });

  test('another login empties the previous member ratings', () async {
    add(fakeRating(1));
    await auth.logout();
    await auth.login('b@umc.com', 'Umc1234!');
    expect(store.ratings, isEmpty);
  });

  test('a late answer from the previous session is not added', () async {
    final oldVersion = store.version;
    await auth.logout();
    store.put(fakeRating(9), version: oldVersion);
    expect(store.ratings, isEmpty);
  });
}
