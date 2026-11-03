import 'package:dio/dio.dart';

import '../models/availability_response.dart';

class MemberCheckService {
  MemberCheckService(this._dio);

  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    return _check('/members/nickname/${Uri.encodeComponent(nickname.trim())}');
  }

  Future<bool> checkEmail(String email) async {
    return _check('/members/email/${Uri.encodeComponent(email.trim())}');
  }

  Future<bool> _check(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    return AvailabilityResponse.fromJson(
      response.data ?? const <String, dynamic>{},
    ).available;
  }
}
