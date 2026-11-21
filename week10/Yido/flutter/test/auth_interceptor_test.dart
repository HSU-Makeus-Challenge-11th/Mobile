import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/auth_interceptor.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/core/network/movie_log_logging_interceptor.dart';

import 'support/fake_token_storage.dart';

/// 실제로 보내지 않고 마지막 요청의 헤더만 기록한다
class _Recorder implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeTokenStorage storage;
  late _Recorder recorder;
  late Dio auth;

  setUp(() {
    storage = FakeTokenStorage('header.payload.signature');
    recorder = _Recorder();
    auth = createAuthMovieLogClient(storage)..httpClientAdapter = recorder;
  });

  String? authorization() => recorder.last!.headers['Authorization'] as String?;

  test('protected paths get the bearer token', () async {
    for (final path in ['/v8/members/me', '/v8/ratings', '/v8/ratings/12']) {
      await auth.get(path);
      expect(authorization(), 'Bearer header.payload.signature', reason: path);
    }
  });

  test('favorite and movie record requests get the token by method', () async {
    await auth.post('/v8/favorites', data: {'movieId': 550});
    expect(authorization(), 'Bearer header.payload.signature');
    await auth.get('/v8/favorites');
    expect(authorization(), 'Bearer header.payload.signature');
    await auth.get('/v8/favorites/550');
    expect(authorization(), 'Bearer header.payload.signature');
    await auth.delete('/v8/favorites/550');
    expect(authorization(), 'Bearer header.payload.signature');
    await auth.post('/v8/movie-records', data: {'movieId': 550});
    expect(authorization(), 'Bearer header.payload.signature');
  });

  test('favorite paths outside the contract get no token', () async {
    await auth.delete('/v8/favorites');
    expect(authorization(), isNull);
    await auth.get('/v8/favorites/0');
    expect(authorization(), isNull);
    await auth.get('/v8/favorites/abc');
    expect(authorization(), isNull);
    await auth.post('/v8/favorites/550');
    expect(authorization(), isNull);
    await auth.get('/v8/movie-records');
    expect(authorization(), isNull);
  });

  test('public paths and other hosts get no token', () async {
    for (final path in [
      '/v8/auth/login',
      '/v8/members/6/ratings',
      '/v8/members/nickname/a',
      '/v8/ratingsx',
    ]) {
      await auth.get(path);
      expect(authorization(), isNull, reason: path);
    }
    await auth.get('https://image.tmdb.org/v8/ratings');
    expect(authorization(), isNull);
  });

  test('a stale header from the caller is removed', () async {
    storage.token = null;
    await auth.get(
      '/v8/members/me',
      options: Options(headers: {'Authorization': 'Bearer old'}),
    );
    expect(authorization(), isNull);
    await auth.get(
      '/v8/auth/login',
      options: Options(headers: {'Authorization': 'Bearer old'}),
    );
    expect(authorization(), isNull);
  });

  test('a storage failure is a local error, not a request', () async {
    storage.failRead = true;
    recorder.last = null;
    await expectLater(
      auth.get('/v8/members/me'),
      throwsA(
        isA<DioException>().having((e) => e.response, 'response', isNull),
      ),
    );
    expect(recorder.last, isNull);
  });

  test('the public client has no interceptor', () {
    expect(
      createMovieLogClient().interceptors.whereType<AuthInterceptor>(),
      isEmpty,
    );
  });

  test('logs hide the token and the password', () {
    expect(
      MovieLogLoggingInterceptor.maskHeaders({'Authorization': 'Bearer a.b.c'}),
      {'Authorization': 'Bearer ***'},
    );
    expect(
      MovieLogLoggingInterceptor.mask({
        'email': 'a@umc.com',
        'password': 'Umc1234!',
        'result': {'nickname': '시네필', 'accessToken': 'a.b.c'},
      }),
      {
        'email': 'a@umc.com',
        'password': '***',
        'result': {'nickname': '시네필', 'accessToken': '***'},
      },
    );
  });

  test('the auth header is added before the log sees the request', () {
    final interceptors = auth.interceptors.toList();
    expect(
      interceptors.indexWhere((i) => i is AuthInterceptor),
      lessThan(interceptors.indexWhere((i) => i is MovieLogLoggingInterceptor)),
    );
  });
}
