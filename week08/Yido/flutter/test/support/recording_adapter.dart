import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 실제 서버 대신 정해 둔 상태와 본문을 돌려주고 마지막 요청을 기록한다
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.status, [this.body]);
  int status;
  Object? body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final payload = body;
    return ResponseBody.fromString(
      payload == null ? '' : jsonEncode(payload),
      status,
      headers: payload == null
          ? {}
          : {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> ok(Object? result, {String code = 'COMMON200'}) => {
  'isSuccess': true,
  'code': code,
  'message': 'ok',
  'result': result,
};

Map<String, dynamic> fail(String code, [String message = '실패']) => {
  'isSuccess': false,
  'code': code,
  'message': message,
  'result': null,
};
