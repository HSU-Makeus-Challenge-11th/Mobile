import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/create_member_request.dart';
import '../data/services/api_error_message.dart';
import '../data/services/sign_up_service.dart';

enum MemberCheckStatus { idle, loading, available, duplicate, failure }

enum SubmitStatus { idle, submitting, success, error }

final class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._memberCheckService);

  final SignUpService _memberCheckService;

  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;
  String? passwordErrorText;
  String? snackbarMessage;

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
    snackbarMessage = null;
    nicknameCheckStatus = _nickname == _lastDuplicateNickname
        ? MemberCheckStatus.duplicate
        : MemberCheckStatus.idle;
    notifyListeners();
  }

  void onEmailChanged(String value) {
    _email = value.trim();
    snackbarMessage = null;
    emailCheckStatus = _email == _lastDuplicateEmail
        ? MemberCheckStatus.duplicate
        : MemberCheckStatus.idle;
    notifyListeners();
  }

  void onPasswordChanged() {
    passwordErrorText = null;
    notifyListeners();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting) return;
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _memberCheckService.signUp(request);
      final id = response.result?.memberId;
      if (!response.isSuccess || id == null || id < 1) {
        throw StateError('회원가입 결과에 memberId가 없습니다.');
      }
      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      submitStatus = SubmitStatus.error;
      final message = apiErrorMessage(
        error,
        fallback: '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.',
      );
      if (error.response?.statusCode == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } catch (_) {
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    }
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
