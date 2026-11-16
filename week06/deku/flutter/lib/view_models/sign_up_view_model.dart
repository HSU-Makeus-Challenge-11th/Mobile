import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/services/member_check_service.dart';

enum MemberCheckStatus { idle, loading, available, duplicate, failure }

final class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._memberCheckService);

  final MemberCheckService _memberCheckService;

  MemberCheckStatus nicknameCheckStatus = MemberCheckStatus.idle;
  MemberCheckStatus emailCheckStatus = MemberCheckStatus.idle;

  String _nickname = '';
  String _email = '';
  String? _lastCheckedNickname;
  String? _lastCheckedEmail;
  String? _lastDuplicateNickname;
  String? _lastDuplicateEmail;

  String? get lastCheckedNickname => _lastCheckedNickname;
  String? get lastCheckedEmail => _lastCheckedEmail;
  String? get lastDuplicateNickname => _lastDuplicateNickname;
  String? get lastDuplicateEmail => _lastDuplicateEmail;

  bool get canCheckNickname =>
      _nickname.length >= 2 &&
      nicknameCheckStatus != MemberCheckStatus.loading &&
      nicknameCheckStatus != MemberCheckStatus.duplicate;

  bool get canCheckEmail =>
      _isValidEmail(_email) &&
      emailCheckStatus != MemberCheckStatus.loading &&
      emailCheckStatus != MemberCheckStatus.duplicate;

  String? get nicknameErrorText => switch (nicknameCheckStatus) {
    MemberCheckStatus.duplicate => '이미 사용 중인 닉네임입니다.',
    MemberCheckStatus.failure => '닉네임 중복 확인에 실패했습니다. 다시 시도해주세요.',
    _ => null,
  };

  String? get emailErrorText => switch (emailCheckStatus) {
    MemberCheckStatus.duplicate => '이미 사용 중인 이메일입니다.',
    MemberCheckStatus.failure => '이메일 중복 확인에 실패했습니다. 다시 시도해주세요.',
    _ => null,
  };

  String? get nicknameHelperText => switch (nicknameCheckStatus) {
    MemberCheckStatus.loading => '닉네임 사용 가능 여부를 확인 중입니다.',
    MemberCheckStatus.available => '사용 가능한 닉네임입니다.',
    _ => null,
  };

  String? get emailHelperText => switch (emailCheckStatus) {
    MemberCheckStatus.loading => '이메일 사용 가능 여부를 확인 중입니다.',
    MemberCheckStatus.available => '사용 가능한 이메일입니다.',
    _ => null,
  };

  void onNicknameChanged(String value) {
    _nickname = value.trim();
    nicknameCheckStatus = _nickname == _lastDuplicateNickname
        ? MemberCheckStatus.duplicate
        : MemberCheckStatus.idle;
    notifyListeners();
  }

  void onEmailChanged(String value) {
    _email = value.trim();
    emailCheckStatus = _email == _lastDuplicateEmail
        ? MemberCheckStatus.duplicate
        : MemberCheckStatus.idle;
    notifyListeners();
  }

  Future<void> checkNickname() async {
    if (!canCheckNickname) return;
    final checkedValue = _nickname;
    nicknameCheckStatus = MemberCheckStatus.loading;
    notifyListeners();

    try {
      final available = await _memberCheckService.checkNickname(checkedValue);
      if (_nickname != checkedValue) return;
      _lastCheckedNickname = checkedValue;
      if (available) {
        nicknameCheckStatus = MemberCheckStatus.available;
      } else {
        _lastDuplicateNickname = checkedValue;
        nicknameCheckStatus = MemberCheckStatus.duplicate;
      }
    } on DioException {
      if (_nickname != checkedValue) return;
      nicknameCheckStatus = MemberCheckStatus.failure;
    } catch (_) {
      if (_nickname != checkedValue) return;
      nicknameCheckStatus = MemberCheckStatus.failure;
    }
    notifyListeners();
  }

  Future<void> checkEmail() async {
    if (!canCheckEmail) return;
    final checkedValue = _email;
    emailCheckStatus = MemberCheckStatus.loading;
    notifyListeners();

    try {
      final available = await _memberCheckService.checkEmail(checkedValue);
      if (_email != checkedValue) return;
      _lastCheckedEmail = checkedValue;
      if (available) {
        emailCheckStatus = MemberCheckStatus.available;
      } else {
        _lastDuplicateEmail = checkedValue;
        emailCheckStatus = MemberCheckStatus.duplicate;
      }
    } on DioException {
      if (_email != checkedValue) return;
      emailCheckStatus = MemberCheckStatus.failure;
    } catch (_) {
      if (_email != checkedValue) return;
      emailCheckStatus = MemberCheckStatus.failure;
    }
    notifyListeners();
  }
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
}
