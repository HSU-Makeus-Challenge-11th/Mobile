import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/models/login_models.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';

enum AuthStatus { initializing, signedOut, authenticating, signedIn, retryRequired }

enum MemberLoadStatus { idle, loading, success, error }

/// 보호 요청에서 토큰이 없음(2)·무효(3)·만료(4)일 때의 code입니다.
/// 로그인 입력 오류 AUTH401_1은 세션 만료가 아니므로 포함하지 않습니다.
bool isSessionInvalidCode(String? code) =>
    code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authApi, this._memberApi, this._storage);

  final AuthApiService _authApi;
  final MemberApiService _memberApi;
  final TokenStorage _storage;

  AuthStatus status = AuthStatus.initializing;
  MemberInfo? member;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  String? message;
  bool sessionExpired = false;
  bool storageCleanupInProgress = false;

  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;
  bool _disposed = false;
  Future<void>? _tokenWrite;

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// 앱 시작 시: 저장된 토큰을 읽고 GET me로 서버 검증이 끝난 뒤에만 signedIn이 됩니다.
  Future<void> restoreSession() async {
    if (_disposed || storageCleanupInProgress) return;
    final version = ++_sessionVersion;
    status = AuthStatus.initializing;
    message = null;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    _notify();

    try {
      final token = await _storage.readAccessToken();
      if (!_isCurrent(version)) return;
      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        final verifiedMember = await _memberApi.fetchMe();
        if (!_isCurrent(version)) return;
        member = verifiedMember;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
      }
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (isSessionInvalidCode(apiErrorCode(error))) {
        await _clearCurrentSession(expired: true);
        return;
      }
      // 네트워크 실패: 토큰은 지우지 않고 재시도 화면으로 보냅니다.
      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
    }
    _notify();
  }

  /// 신규 로그인: 로그인 API 성공 → 토큰 저장 → signedIn.
  /// 내 정보는 MainScreen이 loadMember()로 불러옵니다.
  Future<void> login(String email, String password) async {
    if (_disposed ||
        storageCleanupInProgress ||
        status == AuthStatus.authenticating) {
      return;
    }
    final version = ++_sessionVersion;
    status = AuthStatus.authenticating;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = false;
    message = null;
    _notify();

    try {
      final result = await _authApi.login(
        LoginRequest(email: email, password: password),
      );
      if (!_isCurrent(version)) return;

      final writing = _storage.saveAccessToken(result.accessToken);
      _tokenWrite = writing;
      try {
        await writing;
      } finally {
        if (identical(_tokenWrite, writing)) _tokenWrite = null;
      }
      if (!_isCurrent(version)) return;

      status = AuthStatus.signedIn;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = apiErrorCode(error) == 'AUTH401_1'
          ? '이메일 또는 비밀번호를 확인해 주세요.'
          : '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = '로그인 정보를 안전하게 저장하지 못했어요.';
    }
    _notify();
  }

  /// 로그인된 상태에서 내 정보를 한 번 불러와 member에 보관합니다.
  Future<void> loadMember({bool force = false}) async {
    if (_disposed || status != AuthStatus.signedIn) return;
    if (memberStatus == MemberLoadStatus.loading) return;
    if (member != null && !force) return; // 이미 있으면 다시 부르지 않습니다.

    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    message = null;
    _notify();

    try {
      final me = await _memberApi.fetchMe();
      if (!_isCurrent(version)) return; // 로그아웃·계정 전환 뒤 늦게 온 응답은 버립니다.
      member = me;
      memberStatus = MemberLoadStatus.success;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (isSessionInvalidCode(apiErrorCode(error))) {
        await _clearCurrentSession(expired: true);
        return;
      }
      memberStatus = MemberLoadStatus.error; // 네트워크 실패: 로그아웃하지 않습니다.
      message = '내 정보를 불러오지 못했어요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    }
    _notify();
  }

  /// 사용자가 직접 누른 로그아웃입니다. 저장된 토큰과 내 정보를 지우고 signedOut이 되며,
  /// Router가 /login으로 보냅니다. 만료 Snackbar는 켜지 않습니다.
  /// 서버의 토큰을 즉시 폐기하는 것은 아니고, 이 기기의 세션만 비웁니다.
  Future<void> logout() => _clearCurrentSession(expired: false);

  /// 다른 ViewModel이 보호 요청에서 AUTH401_2/3/4를 받았을 때 세션 정리를 요청합니다.
  /// _clearCurrentSession()은 private이라 이 공개 메서드를 통해 부릅니다.
  Future<void> expireSession() => _clearCurrentSession(expired: true);

  /// 현재 세션을 끝냅니다: 버전 증가 → 메모리 정리 → signedOut → 저장된 토큰 삭제.
  /// 화면 이동은 하지 않습니다. signedOut이 되면 Router가 /login으로 보냅니다.
  Future<void> _clearCurrentSession({required bool expired}) async {
    if (_disposed || storageCleanupInProgress) return;
    final version = ++_sessionVersion;
    storageCleanupInProgress = true;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = expired;
    status = AuthStatus.signedOut;
    message = null;
    _notify();

    try {
      // 저장 중인 토큰이 있으면 끝날 때까지 기다린 뒤 지웁니다.
      try {
        await _tokenWrite;
      } catch (_) {
        // 저장이 실패했어도 삭제는 시도합니다.
      }
      await _storage.deleteAccessToken();
    } catch (_) {
      if (_isCurrent(version)) {
        message = '저장된 인증 정보를 지우지 못했어요. 앱을 다시 실행하기 전에 확인해 주세요.';
      }
    } finally {
      storageCleanupInProgress = false;
      if (_isCurrent(version)) _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionVersion++;
    super.dispose();
  }
}
