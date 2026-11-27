import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/login_models.dart';

final class AuthApiService {
  AuthApiService(this._publicDio);

  final Dio _publicDio;

  Future<LoginResult> login(LoginRequest request) async {
    final response = await _publicDio.post<dynamic>(
      '/v8/auth/login',
      data: request.toJson(),
    );
    if (response.statusCode != 200 || response.data is! Map) {
      throw const FormatException('로그인 응답 형식이 올바르지 않습니다.');
    }
    final common = CommonResponse<LoginResult>.fromJson(
      (response.data as Map).cast<String, dynamic>(),
      (value) => LoginResult.fromJson((value as Map).cast<String, dynamic>()),
    );
    return common.result ?? (throw const FormatException('로그인 result가 없습니다.'));
  }
}
