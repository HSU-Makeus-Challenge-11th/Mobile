import 'package:dio/dio.dart';

/// 서버 실패 응답의 code(예: AUTH401_2, MEMBER409_1)를 꺼냅니다.
/// 응답 본문이 없거나 형식이 다르면(네트워크 끊김 등) null입니다.
String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final code = data['code'];
  return code is String ? code : null;
}

/// 서버 실패 응답의 message를 꺼냅니다. 입력 필드 아래 오류 문구로 씁니다.
String? apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}
