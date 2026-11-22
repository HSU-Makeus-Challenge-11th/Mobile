import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/storage/token_storage.dart';
import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';

enum AuthStatus { initializing, signedOut, authenticating, signedIn, retryRequired }

enum MemberLoadStatus { idle, loading, success, error }

/// 앱 전체의 MovieLog 사용자 세션 상태.
///
/// - 신규 로그인: 로그인 API 성공 → 토큰 저장 → signedIn → MainScreen.loadMember()
/// - 앱 재시작: 토큰 읽기 → GET /v7/members/me 성공 뒤에만 signedIn (restoreSession)
/// - 세션 만료(AUTH401_2/3/4): _clearCurrentSession(expired: true) → signedOut → Router가 /login
/// - 직접 로그아웃: _clearCurrentSession(expired: false)
///
/// 화면 이동은 하지 않는다. 상태만 바꾸면 GoRouter redirect(refreshListenable)가 처리한다.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authApi, this._memberApi, this._storage);

  final AuthApiService _authApi;
  final MemberApiService _memberApi;
  final TokenStorage _storage;

  AuthStatus status = AuthStatus.initializing;
  MemberInfo? member;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  String? message;

  int _sessionVersion = 0;

  /// 로그인·로그아웃·만료마다 증가한다. 이전 세션에서 늦게 도착한 응답을 버리는 기준이다.
  int get sessionVersion => _sessionVersion;

  /// 만료로 쫓겨났을 때만 true. 로그인 화면이 Snackbar를 한 번 보여준 뒤 끈다.
  bool sessionExpired = false;
  bool storageCleanupInProgress = false;
  bool _disposed = false;
  Future<void>? _tokenWrite;

  /// Router 전용 알림. AuthStatus가 실제로 바뀔 때만 알린다(ValueNotifier는 같은 값이면 알리지 않음).
  /// member 교체·loadMember 같은 변경까지 refreshListenable로 받으면 redirect가 불필요하게 다시 돌아,
  /// 프로필 수정 저장 직후 pop()이 되돌려지는 문제가 있었다.
  final ValueNotifier<AuthStatus> statusListenable =
      ValueNotifier(AuthStatus.initializing);

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;

  void _notify() {
    if (_disposed) return;
    statusListenable.value = status;
    notifyListeners();
  }

  /// 앱 시작 시 저장된 토큰을 서버에서 검증해 세션을 복원한다.
  Future<void> restoreSession() async {
    if (storageCleanupInProgress || _disposed) return;
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
        debugPrint('[Auth] 저장된 토큰 없음 → signedOut');
        status = AuthStatus.signedOut;
      } else {
        debugPrint('[Auth] 저장된 토큰 발견(값 비공개) → GET /v7/members/me로 검증');
        final verifiedMember = await _memberApi.fetchMe();
        if (!_isCurrent(version)) return;
        member = verifiedMember;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
        debugPrint('[Auth] 세션 복원 성공 → signedIn');
      }
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      final code = apiErrorCode(error);
      if (isSessionExpiredCode(code)) {
        debugPrint('[Auth] 세션 복원 실패($code) → 토큰 삭제 후 signedOut');
        await _clearCurrentSession(expired: true);
        return;
      }
      // 네트워크가 잠시 끊겼다고 유효한 토큰을 삭제하지 않는다.
      debugPrint('[Auth] 세션 확인 실패(${error.type}) → retryRequired, 토큰 유지');
      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
    }
    if (_isCurrent(version)) _notify();
  }

  Future<void> login(String email, String password) async {
    if (_disposed ||
        storageCleanupInProgress ||
        status == AuthStatus.authenticating) {
      return;
    }
    status = AuthStatus.authenticating;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = false;
    message = null;
    final version = ++_sessionVersion;
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
      debugPrint('[Auth] 로그인 성공 → 토큰을 secure storage에 저장(값 비공개) → signedIn');
      status = AuthStatus.signedIn;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      // AUTH401_1은 로그인 Form 오류다. 세션 만료 처리(sessionExpired)를 켜지 않는다.
      // 입력 형식 오류(COMMON400)는 서버 message를 그대로 보여 주고, 나머지는 통신 실패로 안내한다.
      message = switch (apiErrorCode(error)) {
        'AUTH401_1' => '이메일 또는 비밀번호를 확인해 주세요.',
        'COMMON400' => apiErrorMessage(error) ?? '입력 형식을 확인해 주세요.',
        _ => '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.',
      };
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = '로그인 정보를 안전하게 저장하지 못했어요.';
    }
    _notify();
  }

  /// MainScreen이 처음 열릴 때 한 번 호출한다. 재시작 복원 때는 이미 member가 있어 다시 부르지 않는다.
  Future<void> loadMember({bool force = false}) async {
    if (_disposed || status != AuthStatus.signedIn) return;
    if (memberStatus == MemberLoadStatus.loading) return;
    if (member != null && !force) return;

    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    _notify();

    try {
      final me = await _memberApi.fetchMe();
      if (!_isCurrent(version)) return; // 로그아웃·계정 전환 뒤 늦게 온 응답 무시
      member = me;
      memberStatus = MemberLoadStatus.success;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (isSessionExpiredCode(apiErrorCode(error))) {
        await _clearCurrentSession(expired: true);
        return;
      }
      memberStatus = MemberLoadStatus.error; // 네트워크 실패: 로그아웃하지 않고 재시도 가능
      message = '내 정보를 불러오지 못했어요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    }
    _notify();
  }

  /// 프로필 수정 성공 응답으로 메모리의 내 정보를 교체한다. GET me를 다시 호출하지 않는다.
  void updateMember(MemberInfo updated) {
    if (_disposed || status != AuthStatus.signedIn) return;
    member = updated;
    _notify();
  }

  /// 다른 ViewModel이 AUTH401_2/3/4를 받았을 때 세션 정리를 요청하는 공개 진입점.
  Future<void> expireSession() => _clearCurrentSession(expired: true);

  /// 마이페이지 앱바의 로그아웃. 만료 Snackbar는 켜지 않는다.
  /// 클라이언트 저장소·메모리 세션만 비우며 서버 토큰 폐기를 보장하지 않는다.
  Future<void> logout() => _clearCurrentSession(expired: false);

  void consumeSessionExpired() {
    sessionExpired = false;
  }

  Future<void> _clearCurrentSession({bool expired = true}) async {
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
      // 진행 중이던 토큰 저장을 기다린 뒤 삭제한다. 정리 중 새 로그인은 막는다.
      try {
        await _tokenWrite;
      } catch (_) {
        // 저장 실패여도 삭제는 시도한다.
      }
      await _storage.deleteAccessToken();
      debugPrint('[Auth] 토큰 삭제 완료 (expired: $expired)');
    } catch (_) {
      if (_isCurrent(version)) {
        message = '저장된 인증 정보를 지우지 못했어요. 앱 재실행 전에 저장소 상태를 확인해 주세요.';
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
    statusListenable.dispose();
    super.dispose();
  }
}
