import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final safeHeaders = Map<String, dynamic>.from(options.headers);
    if (safeHeaders.containsKey('Authorization')) {
      safeHeaders['Authorization'] = 'Bearer ***';
    }

    debugPrint('[TMDB] --> ${options.method} ${options.uri}');
    debugPrint('[TMDB] headers: $safeHeaders');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[TMDB] query: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[TMDB] <-- ${response.statusCode} '
      '${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    debugPrint('[TMDB] response: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[TMDB] xx ${err.response?.statusCode ?? '-'} '
      '${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    debugPrint('[TMDB] error: ${err.message}');
    handler.next(err);
  }
}
