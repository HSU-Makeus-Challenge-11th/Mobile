import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 워크북 백엔드 요청/응답을 디버그 콘솔에 남기는 Interceptor.
/// Authorization Header, password, accessToken은 값 대신 *** 로 가린다.
/// AuthInterceptor 뒤에 등록해야 실제로 붙은 Header 존재 여부를 (가린 채로) 확인할 수 있다.
class MovieLogLoggingInterceptor extends Interceptor {
  static const _masked = '***';
  static const _sensitiveKeys = {'password', 'accessToken', 'refreshToken'};

  Object? _mask(Object? data) {
    if (data is Map) {
      return {
        for (final entry in data.entries)
          entry.key: _sensitiveKeys.contains(entry.key)
              ? _masked
              : _mask(entry.value),
      };
    }
    if (data is List) return data.map(_mask).toList();
    return data;
  }

  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) copy['Authorization'] = 'Bearer $_masked';
    return copy;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[MovieLog 요청] ${options.method} ${options.uri.path}');
    debugPrint('[MovieLog 요청 Header] ${_maskHeaders(options.headers)}');
    if (options.data != null) {
      debugPrint('[MovieLog 요청 Body] ${_mask(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[MovieLog 응답] ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri.path}',
    );
    debugPrint('[MovieLog 응답 Body] ${_mask(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[MovieLog 오류] ${err.response?.statusCode} ${err.requestOptions.method} '
      '${err.requestOptions.uri.path}',
    );
    debugPrint('[MovieLog 오류 Body] ${_mask(err.response?.data)}');
    handler.next(err);
  }
}
