import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:movielog/view_models/submit_status.dart';
import 'package:movielog/widgets/movies/rating_dialog.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_member_services.dart';
import 'support/fake_token_storage.dart';
import 'support/recording_adapter.dart';

void main() {
  group('RatingApiService', () {
    (RatingApiService, RecordingAdapter, RecordingAdapter) service(
      int status, [
      Object? body,
    ]) {
      final public = RecordingAdapter(status, body);
      final auth = RecordingAdapter(status, body);
      Dio dio(RecordingAdapter adapter) =>
          Dio(BaseOptions(baseUrl: 'https://example.com'))
            ..httpClientAdapter = adapter;
      return (RatingApiService(dio(public), dio(auth)), public, auth);
    }

    final rating = {
      'ratingId': 6,
      'movieId': 550,
      'score': 5,
      'comment': null,
      'createdAt': '2026-11-16T09:00:00.000Z',
      'updatedAt': '2026-11-16T09:00:00.000Z',
    };

    test(
      'create goes to /v8/ratings on the auth client without memberId',
      () async {
        final (api, public, auth) = service(201, ok(rating, code: 'COMMON201'));
        final created = await api.createRating(
          const CreateRatingRequest(movieId: 550, score: 5),
        );
        expect(auth.request!.path, '/v8/ratings');
        expect(auth.request!.data, {'movieId': 550, 'score': 5});
        expect(public.request, isNull);
        expect(created.ratingId, 6);
      },
    );

    test('update always sends comment and returns the rating', () async {
      final (api, _, auth) = service(200, ok({...rating, 'score': 3}));
      final updated = await api.updateRating(ratingId: 6, score: 3);
      expect(auth.request!.method, 'PATCH');
      expect(auth.request!.path, '/v8/ratings/6');
      expect(auth.request!.data, {'score': 3, 'comment': null});
      expect(updated.score, 3);
    });

    test('delete accepts 200 with a null result and rejects 204', () async {
      final (api, _, auth) = service(200, ok(null));
      await api.deleteRating(6);
      expect(auth.request!.method, 'DELETE');
      expect(auth.request!.path, '/v8/ratings/6');

      final (oldApi, _, _) = service(204);
      expect(oldApi.deleteRating(6), throwsStateError);
    });

    test('member ratings stay public and are a plain array', () async {
      final (api, public, auth) = service(200, [rating]);
      final list = await api.fetchMemberRatings(6);
      expect(public.request!.path, '/v8/members/6/ratings');
      expect(auth.request, isNull);
      expect(list.single.ratingId, 6);
    });

    test('error helpers read the domain codes', () {
      DioException error(int status, Map<String, dynamic> body) {
        final options = RequestOptions(path: '/');
        return DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: status,
            data: body,
          ),
        );
      }

      expect(
        writeErrorMessage(error(409, failBody('RATING409_1', '이미 남김'))),
        '이미 남김',
      );
      expect(isRatingGone(error(404, failBody('RATING404_1'))), isTrue);
      expect(isRatingGone(error(403, failBody('RATING403_1'))), isFalse);

      final noBody = DioException(requestOptions: RequestOptions(path: '/'));
      expect(writeErrorMessage(noBody), contains('잠시 후'));
    });
  });

  group('request model', () {
    test('score must be a whole number from 1 to 5', () {
      expect(validateServerScore(3), 3);
      expect(() => validateServerScore(0), throwsArgumentError);
      expect(() => validateServerScore(6), throwsArgumentError);
      expect(() => validateServerScore(3.5), throwsArgumentError);
    });

    test('an empty comment is left out', () {
      const request = CreateRatingRequest(movieId: 1, score: 2, comment: '  ');
      expect(request.toJson(), {'movieId': 1, 'score': 2});
    });
  });

  group('MovieDetailViewModel', () {
    late FakeRatingApiService api;
    late AuthViewModel auth;
    late SessionRatingStore store;

    setUp(() {
      api = FakeRatingApiService();
      auth = AuthViewModel(
        FakeAuthApiService(),
        FakeMemberApiService(),
        FakeTokenStorage(),
      );
      store = SessionRatingStore(auth);
    });

    test('signed out fails without a request', () async {
      final viewModel = MovieDetailViewModel(api, store, auth, 550);
      await viewModel.createRating(score: 5);
      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.submitMessage, '로그인 후 평점을 남길 수 있어요.');
      expect(api.created, isEmpty);
    });

    test('sends the TMDB id, keeps the result and maps 409', () async {
      await auth.login('a@umc.com', 'Umc1234!');
      final viewModel = MovieDetailViewModel(api, store, auth, 550);
      await viewModel.createRating(score: 5, comment: '최고');
      expect(viewModel.submitStatus, SubmitStatus.success);
      expect(api.created.single.movieId, 550);
      expect(store.ratings.single.movieId, 550);

      api.writeError = (
        status: 409,
        code: 'RATING409_1',
        message: '이미 이 영화에 평점을 남기셨습니다.',
      );
      await viewModel.createRating(score: 5);
      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.submitMessage, '이미 이 영화에 평점을 남기셨습니다.');
      expect(auth.status, AuthStatus.signedIn);
    });

    test('an expired token ends the session', () async {
      await auth.login('a@umc.com', 'Umc1234!');
      final viewModel = MovieDetailViewModel(api, store, auth, 550);
      api.writeError = (status: 401, code: 'AUTH401_3', message: '무효');
      await viewModel.createRating(score: 5);
      expect(auth.status, AuthStatus.signedOut);
      expect(auth.sessionExpired, isTrue);
    });
  });

  group('RatingDialog', () {
    Finder confirm() => find.descendant(
      of: find.byKey(const Key('confirmRatingButton')),
      matching: find.byType(ElevatedButton),
    );

    Future<void> tapStar(WidgetTester tester, int index) async {
      final stars = find.descendant(
        of: find.byType(RatingBar),
        matching: find.byType(GestureDetector),
      );
      await tester.tapAt(tester.getRect(stars.at(index)).center);
      await tester.pump();
    }

    testWidgets('confirm needs a score and typing keeps after picking one', (
      tester,
    ) async {
      await pumpDialog(tester, (_, _) async {});
      expect(tester.widget<ElevatedButton>(confirm()).onPressed, isNull);

      await tester.enterText(find.byKey(const Key('ratingCommentField')), '명작');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(confirm()).onPressed, isNull);

      await tapStar(tester, 3);
      expect(tester.widget<ElevatedButton>(confirm()).onPressed, isNotNull);
      expect(find.text('명작'), findsOneWidget);
    });

    testWidgets('edit starts from the existing score and comment', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        (_, _) async {},
        initialScore: 4,
        initialComment: '다시 봐도 좋아요',
      );
      expect(find.text('다시 봐도 좋아요'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(confirm()).onPressed, isNotNull);
    });

    testWidgets('sends score and a trimmed comment, null when empty', (
      tester,
    ) async {
      final calls = <(int, String?)>[];
      await pumpDialog(tester, (score, comment) async {
        calls.add((score, comment));
      }, initialScore: 4);
      await tester.enterText(
        find.byKey(const Key('ratingCommentField')),
        '   ',
      );
      await tester.tap(confirm());
      await tester.pumpAndSettle();
      expect(calls.single, (4, null));
      expect(find.byType(RatingDialog), findsNothing);
    });

    testWidgets('cancel does not call onSubmit', (tester) async {
      var called = false;
      await pumpDialog(tester, (_, _) async => called = true, initialScore: 4);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(called, isFalse);
      expect(find.byType(RatingDialog), findsNothing);
    });

    testWidgets('saving blocks closing and failure keeps the input', (
      tester,
    ) async {
      final gate = Completer<void>();
      await pumpDialog(tester, (_, _) async {
        await gate.future;
        throw StateError('이미 이 영화에 평점을 남기셨습니다.');
      }, initialScore: 4);
      await tester.enterText(find.byKey(const Key('ratingCommentField')), '명작');
      await tester.tap(confirm());
      await tester.pump();

      expect(
        tester.widget<PopScope>(find.byType(PopScope).last).canPop,
        isFalse,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<ElevatedButton>(confirm()).onPressed, isNull);

      gate.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('이미 이 영화에 평점을 남기셨습니다.'), findsOneWidget);
      expect(find.text('명작'), findsOneWidget);
      expect(
        tester.widget<PopScope>(find.byType(PopScope).last).canPop,
        isTrue,
      );
      expect(tester.widget<ElevatedButton>(confirm()).onPressed, isNotNull);
    });
  });
}

Future<void> pumpDialog(
  WidgetTester tester,
  Future<void> Function(int, String?) onSubmit, {
  int initialScore = 0,
  String? initialComment,
  bool showAddToFavorite = false,
  void Function(bool addToFavorites)? onAddToFavorites,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => RatingDialog(
              initialScore: initialScore,
              initialComment: initialComment,
              showAddToFavorite: showAddToFavorite,
              onSubmit: (score, comment, addToFavorites) {
                onAddToFavorites?.call(addToFavorites);
                return onSubmit(score, comment);
              },
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
