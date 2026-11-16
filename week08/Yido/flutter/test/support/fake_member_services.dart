import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/models/sign_up_models.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';

/// duplicated에 있는 값만 중복으로 답하고, 요청 기록을 남긴다
class FakeSignUpService extends SignUpService {
  FakeSignUpService({this.duplicated = const {}, this.fail = false})
    : super(Dio());

  final Set<String> duplicated;
  bool fail;

  /// 값을 넣으면 응답을 그 Completer가 끝날 때까지 붙잡아 둔다
  final pending = <String, Completer<void>>{};
  final nicknameCalls = <String>[];
  final emailCalls = <String>[];

  Future<bool> _answer(String value) async {
    await pending[value]?.future;
    if (fail) {
      throw DioException(requestOptions: RequestOptions(path: '/v5/members'));
    }
    return !duplicated.contains(value);
  }

  /// 값을 넣으면 회원가입이 그 상태 코드와 메시지로 실패한다
  ({int status, String code, String message})? signUpError;
  bool signUpWithoutId = false;
  Completer<void>? signUpGate;
  final signUpRequests = <CreateMemberRequest>[];

  @override
  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    signUpRequests.add(request);
    await signUpGate?.future;
    final error = signUpError;
    if (error != null) {
      final options = RequestOptions(path: '/v6/members');
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: error.status,
          data: {
            'isSuccess': false,
            'code': error.code,
            'message': error.message,
            'result': null,
          },
        ),
      );
    }
    return CommonResponse(
      isSuccess: true,
      code: 'COMMON201',
      message: '회원가입에 성공했습니다.',
      result: signUpWithoutId
          ? null
          : SignUpResult(
              memberId: 77,
              email: request.email,
              nickname: request.nickname,
            ),
    );
  }

  @override
  Future<bool> checkNickname(String nickname) {
    nicknameCalls.add(nickname);
    return _answer(nickname);
  }

  @override
  Future<bool> checkEmail(String email) {
    emailCalls.add(email);
    return _answer(email);
  }
}

RatingDto fakeRating(
  int id, {
  int movieId = 550,
  String? comment = '최고의 영화!',
}) => RatingDto(
  ratingId: id,
  movieId: movieId,
  score: 5,
  comment: comment,
  createdAt: DateTime.utc(2026, 9, 6, 12),
);

class FakeRatingApiService extends RatingApiService {
  FakeRatingApiService() : super(Dio(), Dio());

  /// 값을 넣으면 쓰기 요청이 그 상태 코드와 code로 실패한다
  ({int status, String code, String message})? writeError;
  Completer<void>? writeGate;
  int _nextId = 100;
  final created = <CreateRatingRequest>[];
  final updated = <({int ratingId, int score, String? comment})>[];
  final deleted = <int>[];

  Future<void> _write(String path) async {
    await writeGate?.future;
    final error = writeError;
    if (error == null) return;
    final options = RequestOptions(path: path);
    throw DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: error.status,
        data: {
          'isSuccess': false,
          'code': error.code,
          'message': error.message,
          'result': null,
        },
      ),
    );
  }

  @override
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    created.add(request);
    await _write('/v7/ratings');
    return RatingDto(
      ratingId: _nextId++,
      movieId: request.movieId,
      score: request.score,
      comment: request.comment,
      createdAt: DateTime(2026, 11, 16),
    );
  }

  @override
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    updated.add((ratingId: ratingId, score: score, comment: comment));
    await _write('/v7/ratings/$ratingId');
    return RatingDto(
      ratingId: ratingId,
      movieId: 550,
      score: score,
      comment: comment,
      createdAt: DateTime(2026, 11, 16),
    );
  }

  @override
  Future<void> deleteRating(int ratingId) async {
    deleted.add(ratingId);
    await _write('/v7/ratings/$ratingId');
  }
}
