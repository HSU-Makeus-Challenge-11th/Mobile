import 'package:dio/dio.dart';

import '../models/availability_response.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_result.dart';

class SignUpService {
  SignUpService(this.dio);

  final Dio dio;

  Future<bool> checkNickname(String nickname) =>
      _check('/v6/members/nickname/${Uri.encodeComponent(nickname.trim())}');

  Future<bool> checkEmail(String email) =>
      _check('/v6/members/email/${Uri.encodeComponent(email.trim())}');

  Future<bool> _check(String path) async {
    final response = await dio.get<Map<String, dynamic>>(path);
    return AvailabilityResponse.fromJson(response.data ?? const {}).available;
  }

  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v6/members',
      data: request.toJson(),
    );
    if (response.statusCode != 201 || response.data == null) {
      throw StateError('회원가입 응답을 확인하지 못했습니다.');
    }
    return CommonResponse<SignUpResult>.fromJson(
      response.data!,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}
