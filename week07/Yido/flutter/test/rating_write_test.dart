import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/submit_status.dart';
import 'package:movielog/widgets/movies/rating_dialog.dart';

import 'support/fake_member_services.dart';

/// 실제 서버 대신 정해 둔 상태와 본문을 돌려주고 요청을 기록한다
class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, [this.body]);
  final int status;
  final String? body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      body ?? '',
      status,
      headers: body == null
          ? {}
          : {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('RatingApiService', () {
    (RatingApiService, _Adapter) service(int status, [String? body]) {
      final adapter = _Adapter(status, body);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = adapter;
      return (RatingApiService(dio), adapter);
    }

    test('create sends movieId and score to the v6 path', () async {
      final (api, adapter) = service(
        201,
        jsonEncode({
          'isSuccess': true,
          'code': 'COMMON201',
          'message': 'ok',
          'result': 6,
        }),
      );
      await api.createRating(
        memberId: 4,
        request: const CreateRatingRequest(movieId: 550, score: 5),
      );
      expect(adapter.request!.path, '/v6/members/4/ratings');
      expect(adapter.request!.data, {'movieId': 550, 'score': 5});
    });

    test('update always sends comment so null stays explicit', () async {
      final (api, adapter) = service(
        200,
        jsonEncode({
          'isSuccess': true,
          'code': 'COMMON200',
          'message': 'ok',
          'result': null,
        }),
      );
      await api.updateRating(memberId: 4, ratingId: 6, score: 3);
      expect(adapter.request!.method, 'PATCH');
      expect(adapter.request!.path, '/v6/members/4/ratings/6');
      expect(adapter.request!.data, {'score': 3, 'comment': null});
    });

    test('delete accepts 204 with an empty body', () async {
      final (api, adapter) = service(204);
      await api.deleteRating(memberId: 4, ratingId: 6);
      expect(adapter.request!.method, 'DELETE');
      expect(adapter.request!.path, '/v6/members/4/ratings/6');
    });

    test('error helpers read the common response', () {
      DioException error(int status, String code, String message) {
        final options = RequestOptions(path: '/');
        return DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: status,
            data: {
              'isSuccess': false,
              'code': code,
              'message': message,
              'result': null,
            },
          ),
        );
      }

      expect(writeErrorMessage(error(409, 'COMMON409', '중복')), '중복');
      expect(
        shouldRefreshAfterRatingError(error(403, 'COMMON403', 'x')),
        isTrue,
      );
      expect(
        shouldRefreshAfterRatingError(error(404, 'COMMON404', 'x')),
        isTrue,
      );
      expect(
        shouldRefreshAfterRatingError(error(400, 'COMMON400', 'x')),
        isFalse,
      );
      expect(
        shouldRefreshAfterRatingError(error(409, 'COMMON409', 'x')),
        isFalse,
      );

      final noBody = DioException(requestOptions: RequestOptions(path: '/'));
      expect(writeErrorMessage(noBody), contains('잠시 후'));
      expect(shouldRefreshAfterRatingError(noBody), isFalse);
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
    test('no member fails without a request', () async {
      final api = FakeRatingApiService();
      final viewModel = MovieDetailViewModel(api, null, 550);
      await viewModel.createRating(score: 5);
      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.submitMessage, '먼저 회원가입을 완료해 주세요.');
      expect(api.created, isEmpty);
    });

    test('sends the TMDB id and maps a 409 to its message', () async {
      final api = FakeRatingApiService();
      final viewModel = MovieDetailViewModel(api, 4, 550);
      await viewModel.createRating(score: 5, comment: '최고');
      expect(viewModel.submitStatus, SubmitStatus.success);
      expect(api.created.single.request.movieId, 550);

      api.writeError = (
        status: 409,
        code: 'COMMON409',
        message: '이미 이 영화에 평점을 남기셨습니다.',
      );
      await viewModel.createRating(score: 5);
      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.submitMessage, '이미 이 영화에 평점을 남기셨습니다.');
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
              onSubmit: onSubmit,
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
