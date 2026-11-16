import 'package:dio/dio.dart';

import '../config/movie_log_config.dart';
import '../storage/token_storage.dart';

String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  return data is Map && data['code'] is String ? data['code'] as String : null;
}

bool isExpiredTokenError(DioException error) =>
    error.response?.statusCode == 401 &&
    const {'AUTH401_2', 'AUTH401_3', 'AUTH401_4'}.contains(apiErrorCode(error));

final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {required this.onExpired});

  final TokenStorage _storage;
  final Future<void> Function() onExpired;

  bool _isProtected(RequestOptions options) {
    if (options.uri.origin != Uri.parse(MovieLogConfig.apiBaseUrl).origin) {
      return false;
    }
    final path = options.uri.path;
    return path == '/v7/members/me' ||
        path == '/v7/ratings' ||
        path.startsWith('/v7/ratings/');
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isProtected(options)) {
      handler.next(options);
      return;
    }
    try {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isProtected(err.requestOptions) && isExpiredTokenError(err)) {
      try {
        final currentToken = await _storage.readAccessToken();
        if (currentToken != null &&
            err.requestOptions.headers['Authorization'] ==
                'Bearer $currentToken') {
          await onExpired();
        }
      } catch (_) {
        // Keep the original API error; a storage failure is handled by auth UI.
      }
    }
    handler.next(err);
  }
}
