import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movielog/data/models/rating_dto.dart';
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
  FakeRatingApiService({this.ratings = const [], this.errorStatus})
    : super(Dio());

  List<RatingDto> ratings;

  /// 0이면 응답 없는 통신 실패, 그 외에는 해당 상태 코드로 실패한다
  int? errorStatus;
  final memberCalls = <int>[];
  Completer<void>? gate;

  @override
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    memberCalls.add(memberId);
    await gate?.future;
    final status = errorStatus;
    if (status != null) {
      final options = RequestOptions(path: '/v5/members/$memberId/ratings');
      throw DioException(
        requestOptions: options,
        response: status == 0
            ? null
            : Response(requestOptions: options, statusCode: status),
      );
    }
    return ratings;
  }
}
