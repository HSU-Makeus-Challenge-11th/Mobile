import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/view_models/auth_view_model.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_token_storage.dart';

void main() {
  late FakeAuthApiService authApi;
  late FakeMemberApiService memberApi;
  late FakeTokenStorage storage;
  late AuthViewModel auth;

  void build([String? token]) {
    authApi = FakeAuthApiService();
    memberApi = FakeMemberApiService();
    storage = FakeTokenStorage(token);
    auth = AuthViewModel(authApi, memberApi, storage);
  }

  group('restoreSession', () {
    test('no token means signedOut without calling me', () async {
      build();
      await auth.restoreSession();
      expect(auth.status, AuthStatus.signedOut);
      expect(memberApi.fetchCount, 0);
    });

    test('a stored token becomes signedIn only after me succeeds', () async {
      build('saved.token');
      memberApi.gate = Completer();
      final restoring = auth.restoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(auth.status, AuthStatus.initializing);
      memberApi.gate!.complete();
      await restoring;
      expect(auth.status, AuthStatus.signedIn);
      expect(auth.member!.nickname, '시네필A');
      expect(auth.memberStatus, MemberLoadStatus.success);
    });

    for (final code in ['AUTH401_2', 'AUTH401_3', 'AUTH401_4']) {
      test('$code clears the token and marks the session expired', () async {
        build('expired.token');
        memberApi.error = apiError('/v8/members/me', 401, code);
        await auth.restoreSession();
        expect(auth.status, AuthStatus.signedOut);
        expect(auth.sessionExpired, isTrue);
        expect(storage.token, isNull);
      });
    }

    test('a network failure keeps the token and asks to retry', () async {
      build('saved.token');
      memberApi.error = networkError('/v8/members/me');
      await auth.restoreSession();
      expect(auth.status, AuthStatus.retryRequired);
      expect(storage.token, 'saved.token');

      memberApi.error = null;
      await auth.restoreSession();
      expect(auth.status, AuthStatus.signedIn);
    });

    test('a storage read failure asks to retry', () async {
      build('saved.token');
      storage.failRead = true;
      await auth.restoreSession();
      expect(auth.status, AuthStatus.retryRequired);
      expect(auth.message, contains('저장소'));
    });
  });

  group('login', () {
    test('saves the token, then signedIn without loading me', () async {
      build();
      await auth.restoreSession();
      await auth.login('a@umc.com', 'Umc1234!');
      expect(auth.status, AuthStatus.signedIn);
      expect(storage.token, 'new.token.value');
      expect(memberApi.fetchCount, 0);
      expect(auth.sessionExpired, isFalse);
    });

    test('AUTH401_1 stays a form error and does not expire', () async {
      build();
      authApi.error = apiError('/v8/auth/login', 401, 'AUTH401_1');
      await auth.login('a@umc.com', 'wrong');
      expect(auth.status, AuthStatus.signedOut);
      expect(auth.message, '이메일 또는 비밀번호를 확인해 주세요.');
      expect(auth.sessionExpired, isFalse);
      expect(storage.deleteCount, 0);
    });

    test('a network failure has a different message', () async {
      build();
      authApi.error = networkError('/v8/auth/login');
      await auth.login('a@umc.com', 'Umc1234!');
      expect(auth.message, '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.');
    });

    test('a second tap while authenticating sends nothing', () async {
      build();
      authApi.gate = Completer();
      final first = auth.login('a@umc.com', 'Umc1234!');
      await auth.login('a@umc.com', 'Umc1234!');
      authApi.gate!.complete();
      await first;
      expect(authApi.requests, hasLength(1));
    });
  });

  group('loadMember', () {
    setUp(() async {
      build();
      await auth.login('a@umc.com', 'Umc1234!');
    });

    test('loads once and reuses the member', () async {
      await auth.loadMember();
      await auth.loadMember();
      expect(memberApi.fetchCount, 1);
      expect(auth.member!.email, 'a@umc.com');
    });

    test('a network failure keeps the session for a retry', () async {
      memberApi.error = networkError('/v8/members/me');
      await auth.loadMember();
      expect(auth.status, AuthStatus.signedIn);
      expect(auth.memberStatus, MemberLoadStatus.error);
      expect(storage.token, isNotNull);
    });

    test('an expired token signs out with the expired notice', () async {
      memberApi.error = apiError('/v8/members/me', 401, 'AUTH401_4');
      await auth.loadMember();
      expect(auth.status, AuthStatus.signedOut);
      expect(auth.sessionExpired, isTrue);
      expect(storage.token, isNull);
    });

    test('a late answer from the old session is ignored', () async {
      memberApi.gate = Completer();
      final loading = auth.loadMember();
      await auth.logout();
      memberApi.gate!.complete();
      await loading;
      expect(auth.member, isNull);
      expect(auth.status, AuthStatus.signedOut);
    });
  });

  test('logout clears token and member without the expired notice', () async {
    build();
    await auth.login('a@umc.com', 'Umc1234!');
    await auth.loadMember();
    await auth.logout();
    expect(auth.status, AuthStatus.signedOut);
    expect(auth.member, isNull);
    expect(auth.sessionExpired, isFalse);
    expect(storage.token, isNull);
  });

  test('expired notice is shown once', () async {
    build();
    await auth.login('a@umc.com', 'Umc1234!');
    await auth.expireSession();
    expect(auth.sessionExpired, isTrue);
    auth.consumeSessionExpired();
    expect(auth.sessionExpired, isFalse);
  });

  test('a late login answer cannot revive a cleared session', () async {
    build();
    authApi.gate = Completer();
    final login = auth.login('a@umc.com', 'Umc1234!');
    await Future<void>.delayed(Duration.zero);
    await auth.logout();
    authApi.gate!.complete();
    await login;
    expect(auth.status, AuthStatus.signedOut);
    expect(storage.token, isNull);
  });

  test('cleanup waits for an in-flight token write before deleting', () async {
    build();
    storage.writeGate = Completer();
    final login = auth.login('a@umc.com', 'Umc1234!');
    await Future<void>.delayed(Duration.zero);
    final logout = auth.logout();
    storage.writeGate!.complete();
    await Future.wait([login, logout]);
    expect(storage.token, isNull);
    expect(auth.status, AuthStatus.signedOut);
  });

  test('two expired 401s run the cleanup once', () async {
    build();
    await auth.login('a@umc.com', 'Umc1234!');
    await Future.wait([auth.expireSession(), auth.expireSession()]);
    expect(storage.deleteCount, 1);
  });
}
