import 'package:dio/dio.dart';
import 'package:movielog/core/storage/token_storage.dart';

/// 워크북 서버의 보호 경로에만 MovieLog JWT를 붙인다
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  final TokenStorage _storage;

  static bool isProtected(RequestOptions options) {
    final path = options.uri.path;
    return options.uri.host == 'workbook.devnoco.com' &&
        (path == '/v8/members/me' ||
            path == '/v8/ratings' ||
            path.startsWith('/v8/ratings/'));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 이전 요청의 토큰을 재사용하지 않는다
    options.headers.remove('Authorization');
    if (!isProtected(options)) {
      handler.next(options);
      return;
    }
    try {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      // 기기 저장소 실패는 서버 401과 다른 오류로 돌려준다
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('인증 저장소를 읽지 못했습니다.'),
        ),
      );
    }
  }
}
