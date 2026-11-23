import 'package:dio/dio.dart';
import 'package:movielog/core/network/auth_interceptor.dart';
import 'package:movielog/core/storage/token_storage.dart';

BaseOptions _movieApiOptions() {
  return BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  );
}

/// 공개 요청용: 로그인, 회원가입, 중복 체크, 유저별 평점 조회 / Interceptor 없음
Dio createMovieApiClient() {
  return Dio(_movieApiOptions());
}

/// 보호 요청용: 내 정보, 평점 등록·수정·삭제 / AuthInterceptor 등록
Dio createAuthMovieApiClient(TokenStorage storage) {
  final dio = Dio(_movieApiOptions());
  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
}
