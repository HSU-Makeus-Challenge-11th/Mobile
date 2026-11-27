import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/auth_interceptor.dart';
import 'auth_view_model.dart';

final class EditProfileViewModel extends ChangeNotifier {
  EditProfileViewModel(this._auth);

  final AuthViewModel _auth;
  bool _disposed = false;
  bool isSaving = false;
  String? fieldError;
  String? message;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> save(String nickname) async {
    if (isSaving) return false;
    final value = nickname.trim();
    if (value.length < 2 || value.length > 12) {
      fieldError = '닉네임은 2~12자로 입력해 주세요.';
      _notify();
      return false;
    }
    if (value == _auth.member?.nickname) return true;
    isSaving = true;
    fieldError = null;
    message = null;
    _notify();
    try {
      return await _auth.updateNickname(value);
    } on DioException catch (error) {
      if (apiErrorCode(error) == 'MEMBER409_1') {
        fieldError = '이미 사용 중인 닉네임입니다.';
      } else if (!isExpiredTokenError(error)) {
        message = '닉네임을 저장하지 못했어요. 다시 시도해 주세요.';
      }
      return false;
    } catch (_) {
      message = '닉네임 응답을 처리하지 못했어요. 다시 시도해 주세요.';
      return false;
    } finally {
      isSaving = false;
      _notify();
    }
  }

  void clearFieldError() {
    if (fieldError == null) return;
    fieldError = null;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
