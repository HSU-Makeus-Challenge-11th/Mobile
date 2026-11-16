import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/auth_interceptor.dart';
import '../core/storage/token_storage.dart';
import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';
import 'session_ratings_store.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

enum MemberLoadStatus { idle, loading, success, error }

final class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authApi, this._memberApi, this._storage, this._ratings);

  final AuthApiService _authApi;
  final MemberApiService _memberApi;
  final TokenStorage _storage;
  final SessionRatingsStore _ratings;

  AuthStatus status = AuthStatus.initializing;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  MemberInfo? member;
  String? message;
  bool sessionExpired = false;
  int _sessionVersion = 0;
  bool _disposed = false;
  Future<void> _storageWrites = Future<void>.value();

  int get sessionVersion => _sessionVersion;
  bool isCurrentSession(int version) =>
      !_disposed && version == _sessionVersion && status == AuthStatus.signedIn;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _runStorageWrite(Future<void> Function() operation) {
    final result = _storageWrites.then((_) => operation());
    _storageWrites = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  Future<void> restoreSession() async {
    if (_disposed) return;
    final version = ++_sessionVersion;
    status = AuthStatus.initializing;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    message = null;
    _notify();
    try {
      await _storageWrites;
      if (version != _sessionVersion) return;
      final token = await _storage.readAccessToken();
      if (version != _sessionVersion) return;
      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        final me = await _memberApi.fetchMe();
        if (version != _sessionVersion) return;
        member = me;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
      }
    } on DioException catch (error) {
      if (version != _sessionVersion) return;
      if (isExpiredTokenError(error)) {
        await expireSession();
        return;
      }
      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (version != _sessionVersion) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
    }
    _notify();
  }

  Future<bool> login(String email, String password) async {
    if (status == AuthStatus.authenticating) return false;
    final version = ++_sessionVersion;
    status = AuthStatus.authenticating;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    message = null;
    sessionExpired = false;
    _ratings.clear();
    _notify();
    try {
      final result = await _authApi.login(
        LoginRequest(email: email, password: password),
      );
      if (version != _sessionVersion) return false;
      try {
        await _runStorageWrite(
          () => _storage.saveAccessToken(result.accessToken),
        );
      } catch (_) {
        if (version != _sessionVersion) return false;
        status = AuthStatus.signedOut;
        message = '토큰을 안전하게 저장하지 못했어요. 다시 시도해 주세요.';
        _notify();
        return false;
      }
      if (version != _sessionVersion) return false;
      status = AuthStatus.signedIn;
      _notify();
      return true;
    } on DioException catch (error) {
      if (version != _sessionVersion) return false;
      status = AuthStatus.signedOut;
      message = apiErrorCode(error) == 'AUTH401_1'
          ? '이메일 또는 비밀번호가 올바르지 않습니다.'
          : '로그인에 실패했습니다. 다시 시도해 주세요.';
    } catch (_) {
      if (version != _sessionVersion) return false;
      status = AuthStatus.signedOut;
      message = '로그인 응답을 처리하지 못했어요. 다시 시도해 주세요.';
    }
    _notify();
    return false;
  }

  Future<void> loadMember({bool force = false}) async {
    if (status != AuthStatus.signedIn ||
        memberStatus == MemberLoadStatus.loading) {
      return;
    }
    if (member != null && !force) return;
    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    message = null;
    _notify();
    try {
      final me = await _memberApi.fetchMe();
      if (!isCurrentSession(version)) return;
      member = me;
      memberStatus = MemberLoadStatus.success;
    } on DioException catch (error) {
      if (!isCurrentSession(version)) return;
      if (isExpiredTokenError(error)) {
        await expireSession();
        return;
      }
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    } catch (_) {
      if (!isCurrentSession(version)) return;
      memberStatus = MemberLoadStatus.error;
      message = '내 정보 응답을 처리하지 못했어요.';
    }
    _notify();
  }

  Future<bool> updateNickname(String nickname) async {
    if (status != AuthStatus.signedIn) return false;
    final version = _sessionVersion;
    final updated = await _memberApi.updateNickname(nickname);
    if (!isCurrentSession(version)) return false;
    member = updated;
    memberStatus = MemberLoadStatus.success;
    _notify();
    return true;
  }

  Future<void> expireSession() async {
    if (status == AuthStatus.signedOut || _disposed) return;
    await _clearSession(expired: true);
  }

  Future<void> logout() => _clearSession(expired: false);

  Future<void> _clearSession({required bool expired}) async {
    final version = ++_sessionVersion;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    message = null;
    sessionExpired = expired;
    _ratings.clear();
    status = AuthStatus.signedOut;
    _notify();
    try {
      await _runStorageWrite(_storage.deleteAccessToken);
    } catch (_) {
      if (version != _sessionVersion) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 정리하지 못했어요. 다시 시도해 주세요.';
      _notify();
    }
  }

  bool consumeSessionExpired() {
    if (!sessionExpired) return false;
    sessionExpired = false;
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
