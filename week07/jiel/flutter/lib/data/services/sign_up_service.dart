import 'package:dio/dio.dart';
import 'package:movielog/data/models/check_result.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/models/sign_up_models.dart';

/// 워크북 자체 백엔드(v6)의 회원가입 관련 API.
/// 6주차 MemberCheckService에서 이름을 바꿨다. 닉네임·이메일 중복 확인은 그대로 두고,
/// 회원가입 POST만 새로 추가했다.
/// 상태를 갖지 않으므로 앱 최상단 Provider에 하나만 등록해 공유한다.
class SignUpService {
  SignUpService(this._dio);
  final Dio _dio;

  /// 사용 가능하면 true, 이미 사용 중이면 false.
  /// v6에서도 성공 응답은 직접 객체 `{ "available": true }`이고, 오류만 공통 형식으로 감싸진다.
  /// 통신 자체가 실패하면 DioException을 그대로 던진다.
  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('/v6/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v6/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  /// POST /v6/members. 성공은 201 + 공통 응답(result에 SignUpResult).
  /// 400(비밀번호 형식 등)·409(이메일/닉네임 중복)는 DioException으로 던진다.
  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post(
      '/v6/members',
      data: request.toJson(),
    );

    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}

/// 회원가입 실패 응답의 message를 그대로 돌려준다.
/// 400 COMMON400(비밀번호 형식)·409 COMMON409(중복) 모두 message에 사용자에게 보여줄 문장이
/// 들어 있으므로 code별 canned 문구를 따로 만들지 않는다.
String writeSignUpErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}
