import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';

enum EditProfileStatus { idle, saving, success, failure }

/// 프로필 수정(닉네임) 화면의 저장 상태와 오류를 관리합니다.
class EditProfileViewModel extends ChangeNotifier {
  EditProfileViewModel(this._memberApi, this._auth);

  final MemberApiService _memberApi;
  final AuthViewModel _auth;

  EditProfileStatus status = EditProfileStatus.idle;
  String? nicknameError; // 닉네임 칸 아래에 보여줄 오류(길이·중복)
  String? message; // Snackbar로 보여줄 오류(네트워크 등)
  bool _disposed = false;

  /// 서버에 보내기 전에 확인할 수 있는 규칙은 먼저 검사합니다.
  String? validateNickname(String value) {
    final nickname = value.trim();
    if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
    if (nickname.length < 2 || nickname.length > 12) {
      return '닉네임은 2~12자로 입력해 주세요.';
    }
    return null;
  }

  /// 입력을 고치기 시작하면 이전 오류 문구를 지웁니다.
  void onNicknameChanged() {
    if (nicknameError == null) return;
    nicknameError = null;
    _notify();
  }

  Future<bool> save(String input) async {
    if (status == EditProfileStatus.saving) return false; // 중복 탭 방지
    if (_disposed ||
        _auth.status != AuthStatus.signedIn ||
        _auth.member == null) {
      return false;
    }
    final version = _auth.sessionVersion;
    final nickname = input.trim();

    nicknameError = validateNickname(nickname);
    message = null;
    if (nicknameError != null) {
      _notify();
      return false;
    }

    // 지금 닉네임과 같으면 요청 없이 완료로 처리합니다(서버도 409가 아니지만 보낼 이유가 없음).
    if (nickname == _auth.member?.nickname) {
      status = EditProfileStatus.success;
      _notify();
      return true;
    }

    status = EditProfileStatus.saving;
    _notify();

    try {
      final updated = await _memberApi.updateNickname(nickname);
      if (version != _auth.sessionVersion) return false; // 로그아웃 뒤 늦은 응답
      _auth.updateMember(updated); // 마이페이지가 바로 새 닉네임을 보여줍니다.
      if (_disposed) return false;
      status = EditProfileStatus.success;
      _notify();
      return true;
    } on DioException catch (error) {
      if (version != _auth.sessionVersion) return false;
      final code = apiErrorCode(error);
      if (isSessionInvalidCode(code)) {
        // 세션 만료: 정리하면 Router가 /login으로 보냅니다.
        await _auth.expireSession();
        return false;
      }
      if (_disposed) return false;
      status = EditProfileStatus.failure;
      if (code == 'MEMBER409_1') {
        nicknameError = '이미 사용 중인 닉네임이에요.'; // 입력값은 그대로 둡니다.
      } else if (code == 'COMMON400') {
        nicknameError = apiErrorMessage(error) ?? '닉네임 형식을 확인해 주세요.';
      } else if (code == 'MEMBER404_1') {
        message = '회원 정보를 찾을 수 없어요.';
      } else {
        message = '네트워크 상태를 확인하고 다시 시도해 주세요.'; // 로그아웃하지 않습니다.
      }
    } catch (_) {
      if (_disposed || version != _auth.sessionVersion) return false;
      status = EditProfileStatus.failure;
      message = '알 수 없는 오류가 발생했어요.';
    }
    _notify();
    return false;
  }

  /// 화면이 사라진 뒤 도착한 응답이 notifyListeners()를 부르지 않게 막습니다.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
