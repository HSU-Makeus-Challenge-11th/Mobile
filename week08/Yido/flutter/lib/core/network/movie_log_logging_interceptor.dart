import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 디버그 모드에서만 워크북 요청을 남긴다. 토큰과 비밀번호는 가린 뒤 출력한다
class MovieLogLoggingInterceptor extends Interceptor {
  static const _hidden = {'password', 'accessToken'};

  static Object? mask(Object? data) => switch (data) {
    Map() => {
      for (final MapEntry(:key, :value) in data.entries)
        key: _hidden.contains(key) ? '***' : mask(value),
    },
    List() => [for (final value in data) mask(value)],
    _ => data,
  };

  static Map<String, dynamic> maskHeaders(Map<String, dynamic> headers) => {
    for (final MapEntry(:key, :value) in headers.entries)
      key: key.toLowerCase() == 'authorization' ? 'Bearer ***' : value,
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final auth = options.headers.keys.any(
        (key) => key.toLowerCase() == 'authorization',
      );
      debugPrint('[MovieLog 요청] ${options.method} ${options.path}');
      if (auth) {
        debugPrint('[MovieLog 요청 Header] ${maskHeaders(options.headers)}');
      }
      if (options.data != null) {
        debugPrint('[MovieLog 요청 Body] ${mask(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[MovieLog 응답] ${response.statusCode} ${response.requestOptions.path} '
        '${mask(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[MovieLog 오류] ${err.response?.statusCode} ${err.requestOptions.path} '
        '${mask(err.response?.data)}',
      );
    }
    handler.next(err);
  }
}
