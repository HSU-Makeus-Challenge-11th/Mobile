import 'package:dio/dio.dart';

/// 서버 공통 오류 응답 `{ isSuccess, code, message, result }`에서 code를 꺼낸다.
/// body가 없거나 Map이 아니면(타임아웃, 네트워크 끊김 등) null.
String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final code = data['code'];
  return code is String ? code : null;
}

/// 서버 공통 오류 응답의 message. 입력 검증(COMMON400) 안내처럼 서버 문장을 그대로 보여줄 때 쓴다.
String? apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}

/// 보호 요청에서 토큰이 없거나(2) / 무효하거나(3) / 만료된(4) 경우.
/// 로그인 입력 오류 AUTH401_1은 여기에 포함하지 않는다(로그인 Form 오류).
bool isSessionExpiredCode(String? code) =>
    code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
