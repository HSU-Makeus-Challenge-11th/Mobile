import 'package:dio/dio.dart';
import 'package:movielog/core/network/auth_interceptor.dart';
import 'package:movielog/core/storage/token_storage.dart';

/// 워크북 자체 백엔드용 설정. baseUrl과 헤더가 다른 TMDB Client와 합치지 않는다
BaseOptions _movieLogOptions() => BaseOptions(
  baseUrl: 'https://workbook.devnoco.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
);

/// 공개 요청용: 로그인, 회원가입, 중복 체크, 유저별 평점 조회. Interceptor가 없다
Dio createMovieLogClient() => Dio(_movieLogOptions());

/// 보호 요청용: 내 정보, 평점 등록·수정·삭제. 이 Client에만 토큰을 붙인다
Dio createAuthMovieLogClient(TokenStorage storage) {
  final dio = Dio(_movieLogOptions());
  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
}
