import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/auth_session_bridge.dart';
import 'package:movielog/core/session/session_guard.dart';

class _Signals extends ChangeNotifier {
  int version = 0;
  String? email;
  void set(int nextVersion, String? nextEmail) {
    version = nextVersion;
    email = nextEmail;
    notifyListeners();
  }
}

void main() {
  test('a new session makes older generations stale', () {
    final guard = SessionGuard();
    final first = guard.startSession('a@umc.com');
    expect(guard.isCurrent(first, 'a@umc.com'), isTrue);
    final second = guard.startSession('a@umc.com');
    expect(guard.isCurrent(first, 'a@umc.com'), isFalse);
    expect(guard.isCurrent(second, 'a@umc.com'), isTrue);
    expect(guard.isCurrent(second, 'b@umc.com'), isFalse);
    guard.invalidate();
    expect(guard.isCurrent(second, 'a@umc.com'), isFalse);
    expect(guard.accountId, isNull);
  });

  test('the bridge starts a session only after the email is verified', () {
    final signals = _Signals();
    final bridge = AuthSessionBridge(
      authSignals: signals,
      sessionVersion: () => signals.version,
      verifiedEmail: () => signals.email,
    );
    expect(bridge.guard.accountId, isNull);

    signals.set(1, null); // 로그인 직후, 내 정보 조회 전
    expect(bridge.guard.accountId, isNull);
    signals.set(1, 'a@umc.com');
    expect(bridge.guard.accountId, 'a@umc.com');
    final generation = bridge.guard.generation;

    signals.set(1, 'a@umc.com'); // 닉네임 수정처럼 값이 그대로인 알림
    expect(bridge.guard.generation, generation);

    signals.set(2, null); // 로그아웃
    expect(bridge.guard.isCurrent(generation, 'a@umc.com'), isFalse);
    signals.set(3, 'b@umc.com'); // 다른 계정으로 로그인
    expect(bridge.guard.accountId, 'b@umc.com');

    signals.set(5, 'a@umc.com');
    final relogin = bridge.guard.generation;
    signals.set(7, 'a@umc.com'); // 같은 이메일로 다시 로그인해도 새 세션이다
    expect(bridge.guard.generation, isNot(relogin));

    bridge.dispose();
    expect(bridge.guard.accountId, isNull);
  });
}
