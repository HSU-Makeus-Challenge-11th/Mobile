import 'package:flutter/foundation.dart';
import 'package:movielog/core/session/session_guard.dart';

/// AuthViewModel의 상태 변화를 SessionGuard에 전달합니다.
/// 연결만 담당하고, 로그인 상태의 기준은 8주차 AuthViewModel이 그대로 가집니다.
///
/// - sessionVersion이 바뀌면(로그인·로그아웃·만료) 기존 세션을 무효화합니다.
/// - 내 정보(GET me)로 확인한 email이 생기면 그 email로 새 세션을 시작합니다.
/// - 닉네임 수정처럼 version과 email이 그대로인 알림에서는 아무것도 하지 않습니다.
class AuthSessionBridge {
  AuthSessionBridge({
    required this.authSignals,
    required this.sessionVersion,
    required this.verifiedEmail,
  }) {
    authSignals.addListener(_sync);
    _sync();
  }

  final Listenable authSignals;
  final int Function() sessionVersion;

  /// signedIn이고 내 정보 조회가 끝나 member가 생기기 전까지는 null을 반환합니다.
  final String? Function() verifiedEmail;

  final guard = SessionGuard();
  int? _seenVersion;
  String? _seenEmail;
  bool _disposed = false;

  void _sync() {
    if (_disposed) return;
    final version = sessionVersion();
    final email = verifiedEmail();
    if (version == _seenVersion && email == _seenEmail) return;
    _seenVersion = version;
    _seenEmail = email;
    guard.invalidate();
    if (email != null) guard.startSession(email);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    authSignals.removeListener(_sync);
    guard.invalidate();
  }
}
