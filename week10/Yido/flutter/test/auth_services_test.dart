import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/login_models.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';

import 'support/recording_adapter.dart';

void main() {
  Dio dio(RecordingAdapter adapter) =>
      Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = adapter;

  test('login posts trimmed email and reads token and nickname', () async {
    final adapter = RecordingAdapter(
      200,
      ok({'nickname': '영화광', 'accessToken': 'a.b.c'}),
    );
    final result = await AuthApiService(dio(adapter))
        .login(const LoginRequest(email: ' a@umc.com ', password: ' Pw1! '));
    expect(adapter.request!.path, '/v8/auth/login');
    expect(adapter.request!.data, {'email': 'a@umc.com', 'password': ' Pw1! '});
    expect(result.nickname, '영화광');
    expect(result.accessToken, 'a.b.c');
  });

  test('login without result is an error, not an empty token', () async {
    final adapter = RecordingAdapter(200, ok(null));
    expect(
      AuthApiService(dio(adapter))
          .login(const LoginRequest(email: 'a@umc.com', password: 'x')),
      throwsStateError,
    );
  });

  test('me and nickname update parse the wrapped member', () async {
    final member = {
      'email': 'a@umc.com',
      'nickname': '시네필',
      'createdAt': '2026-10-10T09:00:00.000Z',
    };
    final adapter = RecordingAdapter(200, ok(member));
    final api = MemberApiService(dio(adapter));

    final me = await api.fetchMe();
    expect(adapter.request!.path, '/v8/members/me');
    expect(me.nickname, '시네필');
    expect(me.createdAt, DateTime.utc(2026, 10, 10, 9));

    await api.updateNickname('새닉네임');
    expect(adapter.request!.method, 'PATCH');
    expect(adapter.request!.data, {'nickname': '새닉네임'});
  });
}
