import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/movie_record_models.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/services/movie_record_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:movielog/view_models/submit_status.dart';

import 'rating_write_test.dart' show pumpDialog;
import 'support/fake_auth_services.dart';
import 'support/fake_member_services.dart';
import 'support/fake_token_storage.dart';

class _FakeRecordApi extends MovieRecordApiService {
  _FakeRecordApi() : super(Dio());
  final requests = <CreateMovieRecordRequest>[];
  Object? error;

  @override
  Future<MovieRecordDto> createMovieRecord(
    CreateMovieRecordRequest request,
  ) async {
    requests.add(request);
    final failure = error;
    if (failure != null) throw failure;
    return MovieRecordDto(
      rating: RatingDto(
        ratingId: 9,
        movieId: request.movieId,
        score: request.score,
        comment: request.comment,
        createdAt: DateTime(2026, 11, 20),
      ),
    );
  }
}

void main() {
  late FakeRatingApiService ratingApi;
  late _FakeRecordApi recordApi;
  late SessionRatingStore store;
  late AuthViewModel auth;

  setUp(() async {
    ratingApi = FakeRatingApiService();
    recordApi = _FakeRecordApi();
    auth = AuthViewModel(
      FakeAuthApiService(),
      FakeMemberApiService(),
      FakeTokenStorage(),
    );
    await auth.login('a@umc.com', 'Umc1234!');
    store = SessionRatingStore(auth);
  });

  MovieDetailViewModel create() => MovieDetailViewModel(
    ratingApi,
    store,
    auth,
    550,
    movieRecordApi: recordApi,
  );

  test('not-yet-favorite movies save through movie-records', () async {
    final vm = create();
    await vm.saveRating(
      score: 3,
      comment: '예시 후기',
      viaMovieRecord: true,
      addToFavorites: true,
    );
    expect(vm.submitStatus, SubmitStatus.success);
    expect(recordApi.requests.single.toJson(), {
      'movieId': 550,
      'score': 3,
      'comment': '예시 후기',
      'addToFavorites': true,
    });
    expect(ratingApi.created, isEmpty);
    expect(store.ratings.single.ratingId, 9);
  });

  test('already-favorite movies use the plain rating API', () async {
    final vm = create();
    await vm.saveRating(score: 4);
    expect(recordApi.requests, isEmpty);
    expect(ratingApi.created.single.score, 4);
  });

  test('409 and member errors close the dialog, others keep it', () async {
    final vm = create();
    for (final (code, close) in const [
      ('RATING409_1', true),
      ('FAVORITE409_1', true),
      ('MEMBER404_1', true),
      ('COMMON400', false),
    ]) {
      recordApi.error = apiError('/v8/movie-records', 400, code);
      await vm.saveRating(score: 3, viaMovieRecord: true);
      expect(vm.submitStatus, SubmitStatus.error);
      expect(vm.closeDialogOnError, close, reason: code);
    }
    recordApi.error = networkError('/v8/movie-records');
    await vm.saveRating(score: 3, viaMovieRecord: true);
    expect(vm.closeDialogOnError, isFalse);
  });

  testWidgets('the checkbox shows only when asked and is sent', (tester) async {
    bool? sent;
    await pumpDialog(
      tester,
      (_, _) async {},
      showAddToFavorite: true,
      onAddToFavorites: (value) => sent = value,
    );
    expect(find.text('즐겨찾기에도 추가'), findsOneWidget);
    await tester.tap(find.byKey(const Key('addToFavoriteCheckbox')));
    final stars = find.descendant(
      of: find.byType(RatingBar),
      matching: find.byType(GestureDetector),
    );
    await tester.tapAt(tester.getRect(stars.at(2)).center);
    await tester.pump();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(sent, isTrue);

    await pumpDialog(tester, (_, _) async {});
    expect(find.text('즐겨찾기에도 추가'), findsNothing);
  });
}
