import 'package:dio/dio.dart';

/// 오류 응답 body의 code를 꺼낸다. 공통 형식이 아니면 null이다
String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final code = data['code'];
  return code is String ? code : null;
}

String? apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}

/// 보호 요청에서 토큰이 없거나(2) 무효이거나(3) 만료된(4) 경우다.
/// 로그인 입력 오류 AUTH401_1은 세션 만료가 아니므로 포함하지 않는다
bool isSessionExpiredError(DioException error) {
  final code = apiErrorCode(error);
  return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
}
