import 'package:deku/data/models/rating.dart';
import 'package:deku/data/models/create_member_request.dart';
import 'package:deku/data/models/rating_request.dart';
import 'package:deku/data/services/rating_api_service.dart';
import 'package:deku/data/services/sign_up_service.dart';
import 'package:deku/screens/my_ratings/my_ratings_screen.dart';
import 'package:deku/services/movie_service.dart';
import 'package:deku/theme/app_theme.dart';
import 'package:deku/view_models/my_ratings_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v6 평점 요청은 정수 점수와 실제 영화 ID를 보낸다', () {
    expect(validateServerScore(4), 4);
    expect(() => validateServerScore(3.5), throwsArgumentError);
    expect(
      const CreateRatingRequest(
        movieId: 550,
        score: 4,
        comment: ' 좋았어요 ',
      ).toJson(),
      {'movieId': 550, 'score': 4, 'comment': '좋았어요'},
    );
  });

  test('회원가입은 v6 경로와 공통 응답의 memberId를 사용한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://workbook.devnoco.com'));
    String? path;
    Object? body;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          body = options.data;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'isSuccess': true,
                'code': 'COMMON201',
                'message': '가입 완료',
                'result': {
                  'memberId': 42,
                  'email': 'movie@example.com',
                  'nickname': '무비러버',
                },
              },
            ),
          );
        },
      ),
    );

    final response = await SignUpService(dio).signUp(
      const CreateMemberRequest(
        email: ' movie@example.com ',
        password: 'Password1!',
        nickname: ' 무비러버 ',
      ),
    );

    expect(path, '/v6/members');
    expect(body, {
      'email': 'movie@example.com',
      'password': 'Password1!',
      'nickname': '무비러버',
    });
    expect(response.result?.memberId, 42);
  });

  test('평점 조회 배열과 본문 없는 DELETE 204를 각각 처리한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://workbook.devnoco.com'));
    final paths = <String>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          paths.add(options.path);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: options.method == 'DELETE' ? 204 : 200,
              data: options.method == 'DELETE'
                  ? null
                  : [
                      {
                        'ratingId': 3,
                        'movieId': 550,
                        'score': 4,
                        'comment': null,
                      },
                    ],
            ),
          );
        },
      ),
    );

    final service = RatingApiService(dio);
    final ratings = await service.fetchMyRatings(42);
    await service.deleteRating(memberId: 42, ratingId: 3);

    expect(ratings.single.movieId, 550);
    expect(paths, ['/v6/members/42/ratings', '/v6/members/42/ratings/3']);
  });

  test('다중 삭제 일부 실패 시 성공한 항목만 제거하고 실패 선택은 유지한다', () async {
    final service = _MemoryRatingService([_rating(1), _rating(2), _rating(3)])
      ..failingId = 2;
    final viewModel = MyRatingsViewModel(
      service,
      FakeMovieService(delay: Duration.zero),
    );
    await viewModel.load(memberId: 42);
    viewModel.toggleEditing();
    viewModel.toggleSelection(1);
    viewModel.toggleSelection(2);

    final failed = await viewModel.deleteSelectedRatings();

    expect(failed, 1);
    expect(service.lastMemberId, 42);
    expect(viewModel.items.map((item) => item.rating.ratingId), [2, 3]);
    expect(viewModel.selectedRatingIds, {2});
    expect(viewModel.isDeletingSelected, isFalse);
    expect(viewModel.message, contains('1개 항목'));
    viewModel.dispose();
  });

  testWidgets('편집 모드에서 선택한 평점을 확인 후 삭제한다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _MemoryRatingService([_rating(1), _rating(2)]);
    final viewModel = MyRatingsViewModel(
      service,
      FakeMovieService(delay: Duration.zero),
    );
    await viewModel.load(memberId: 42);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MyRatingsScreen(viewModel: viewModel),
      ),
    );

    expect(find.byKey(const ValueKey('edit-rating-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ratings-edit-mode-button')));
    await tester.pump();
    expect(find.byKey(const ValueKey('select-rating-1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('select-rating-1')));
    await tester.pump();
    expect(find.text('1개 선택됨'), findsOneWidget);
    await tester.tap(find.text('선택한 1개 삭제'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-rating-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-delete-rating-button')));
    await tester.pumpAndSettle();
    expect(service.ratings.map((rating) => rating.ratingId), [2]);
    expect(find.byKey(const ValueKey('my-rating-1')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('단일 삭제는 취소하면 요청하지 않고 확인 후 빈 목록을 표시한다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _MemoryRatingService([_rating(1)]);
    final viewModel = MyRatingsViewModel(
      service,
      FakeMovieService(delay: Duration.zero),
    );
    await viewModel.load(memberId: 42);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MyRatingsScreen(viewModel: viewModel),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('delete-rating-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-rating-dialog')), findsOneWidget);
    await tester.tap(find.text('취소').last);
    await tester.pumpAndSettle();
    expect(service.ratings.length, 1);

    await tester.tap(find.byKey(const ValueKey('delete-rating-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-rating-button')));
    await tester.pumpAndSettle();
    expect(service.ratings, isEmpty);
    expect(find.byKey(const Key('my-ratings-empty')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Rating _rating(int id) =>
    Rating(ratingId: id, movieId: id, score: 4, comment: '좋은 영화였어요');

class _MemoryRatingService extends RatingApiService {
  _MemoryRatingService(this.ratings) : super(Dio());

  final List<Rating> ratings;
  int? failingId;
  int? lastMemberId;

  @override
  Future<List<Rating>> fetchMyRatings(int memberId) async {
    lastMemberId = memberId;
    return List.of(ratings);
  }

  @override
  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    lastMemberId = memberId;
    if (ratingId == failingId) {
      final options = RequestOptions(
        path: '/v6/members/$memberId/ratings/$ratingId',
      );
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 403,
          data: {'code': 'COMMON403', 'message': '본인이 작성한 평점만 삭제할 수 있습니다.'},
        ),
      );
    }
    ratings.removeWhere((rating) => rating.ratingId == ratingId);
  }
}
