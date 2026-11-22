import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'movie_log_logging_interceptor.dart';

/// 워크북 자체 백엔드용 Dio 설정.
/// TMDB Client(createTmdbClient)와 baseUrl·헤더가 다르므로 절대 하나로 합치지 않는다.
BaseOptions _movieLogOptions() {
  return BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'accept': 'application/json'},
  );
}

/// 공개 요청용(6주차 코드 유지): 로그인, 회원가입, 중복 체크, 유저별 평점 조회 / AuthInterceptor 없음
Dio createMovieLogClient() {
  final dio = Dio(_movieLogOptions());
  if (kDebugMode) dio.interceptors.add(MovieLogLoggingInterceptor());
  return dio;
}

/// 보호 요청용(8주차 추가): 내 정보, 평점 등록/수정/삭제 / AuthInterceptor 등록
Dio createAuthMovieLogClient(TokenStorage storage) {
  final dio = Dio(_movieLogOptions());
  dio.interceptors.add(AuthInterceptor(storage));
  // AuthInterceptor 뒤에 두어 Header가 붙었는지를 가린 채로 확인한다.
  if (kDebugMode) dio.interceptors.add(MovieLogLoggingInterceptor());
  return dio;
}
