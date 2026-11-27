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
  AuthInterceptor(
    this._storage, {
    required this.onExpired,
    required this.sessionVersion,
  });

  static const _sessionVersionKey = 'movielog.sessionVersion';
  final TokenStorage _storage;
  final Future<void> Function() onExpired;
  final int Function() sessionVersion;

  bool _isProtected(RequestOptions options) {
    if (options.uri.origin != Uri.parse(MovieLogConfig.apiBaseUrl).origin) {
      return false;
    }
    final path = options.uri.path;
    return path == '/v8/members/me' ||
        path == '/v8/ratings' ||
        path.startsWith('/v8/ratings/') ||
        path == '/v8/favorites' ||
        path.startsWith('/v8/favorites/');
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
      options.extra[_sessionVersionKey] = sessionVersion();
      handler.next(options);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isProtected(err.requestOptions) &&
        isExpiredTokenError(err) &&
        err.requestOptions.extra[_sessionVersionKey] == sessionVersion()) {
      try {
        final currentToken = await _storage.readAccessToken();
        if (currentToken != null &&
            err.requestOptions.extra[_sessionVersionKey] == sessionVersion() &&
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
