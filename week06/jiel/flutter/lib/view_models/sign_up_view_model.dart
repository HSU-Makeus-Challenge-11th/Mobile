import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/services/member_check_service.dart';

/// 중복 확인 한 건의 상태.
/// - idle: 아직 확인하지 않았거나, 입력이 바뀌어 이전 결과가 무효화됨
/// - checking: 요청 진행 중
/// - available: 서버가 사용 가능하다고 응답
/// - duplicated: 서버가 이미 사용 중이라고 응답 (available: false)
/// - error: 통신 자체가 실패 (DioException)
enum CheckStatus { idle, checking, available, duplicated, error }

/// 닉네임·이메일 각각의 중복 확인 상태를 담는 묶음.
/// 두 입력란을 하나의 상태값으로 합치면 서로의 결과가 영향을 주므로 필드별로 분리한다.
class _CheckField {
  CheckStatus status = CheckStatus.idle;
  String? errorText;
  String current = '';
  int requestVersion = 0;
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final MemberCheckService _service;

  final _nickname = _CheckField();
  final _email = _CheckField();
  bool _disposed = false;

  static const _networkErrorText = '중복 확인에 실패했어요. 네트워크를 확인하고 다시 시도해 주세요.';

  // ---- 닉네임 ----
  CheckStatus get nicknameCheckStatus => _nickname.status;
  String? get nicknameErrorText => _nickname.errorText;
  bool get canCheckNickname => _canCheck(_nickname);

  void onNicknameChanged(String value) => _onChanged(_nickname, value);

  Future<void> checkNickname(String value) => _check(
        field: _nickname,
        value: value,
        request: _service.checkNickname,
        duplicatedText: '이미 사용 중인 닉네임입니다.',
      );

  // ---- 이메일 ----
  CheckStatus get emailCheckStatus => _email.status;
  String? get emailErrorText => _email.errorText;
  bool get canCheckEmail => _canCheck(_email);

  void onEmailChanged(String value) => _onChanged(_email, value);

  Future<void> checkEmail(String value) => _check(
        field: _email,
        value: value,
        request: _service.checkEmail,
        duplicatedText: '이미 사용 중인 이메일입니다.',
      );

  /// 두 값 모두 서버에서 사용 가능하다고 확인된 상태인지.
  bool get isAllChecked =>
      _nickname.status == CheckStatus.available &&
      _email.status == CheckStatus.available;

  // ---- 공통 로직 ----
  bool _canCheck(_CheckField field) =>
      field.status != CheckStatus.checking && field.current.isNotEmpty;

  /// 입력이 바뀌면 이전 확인 결과를 즉시 무효화한다.
  void _onChanged(_CheckField field, String value) {
    final trimmed = value.trim();
    if (trimmed == field.current) return; // 앞뒤 공백만 바뀐 경우는 결과 유지
    field.current = trimmed;
    field.requestVersion++; // 기다리던 이전 요청의 응답을 무시하도록 버전을 올린다.
    field.status = CheckStatus.idle;
    field.errorText = null;
    _notify();
  }

  Future<void> _check({
    required _CheckField field,
    required String value,
    required Future<bool> Function(String) request,
    required String duplicatedText,
  }) async {
    final requested = value.trim();
    if (requested.isEmpty || requested != field.current || !_canCheck(field)) {
      return;
    }

    final version = ++field.requestVersion;
    field.status = CheckStatus.checking;
    field.errorText = null;
    _notify();

    bool isStale() =>
        _disposed || version != field.requestVersion || field.current != requested;

    try {
      final available = await request(requested);
      if (isStale()) return;
      field.status = available ? CheckStatus.available : CheckStatus.duplicated;
      field.errorText = available ? null : duplicatedText;
    } on DioException catch (error) {
      if (isStale()) return;
      debugPrint('중복 확인 실패: ${error.type} ${error.message}');
      field.status = CheckStatus.error;
      field.errorText = _networkErrorText;
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _nickname.requestVersion++;
    _email.requestVersion++;
    super.dispose();
  }
}
