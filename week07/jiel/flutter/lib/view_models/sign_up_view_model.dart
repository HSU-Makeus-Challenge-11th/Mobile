import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/view_models/submit_status.dart';

export 'package:movielog/view_models/submit_status.dart';

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

  void invalidate() {
    requestVersion++; // 기다리던 이전 요청의 응답을 무시하도록 버전을 올린다.
    status = CheckStatus.idle;
    errorText = null;
  }
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final SignUpService _service;

  final _nickname = _CheckField();
  final _email = _CheckField();
  bool _disposed = false;

  static const _networkErrorText = '중복 확인에 실패했어요. 네트워크를 확인하고 다시 시도해 주세요.';

  // ---- 회원가입 제출 ----
  SubmitStatus submitStatus = SubmitStatus.idle;

  /// 가입 성공 응답에서 읽은 실제 ID. 화면이 LearningMemberSession에 저장한다.
  int? createdMemberId;

  /// 서버가 비밀번호 형식 위반(400)으로 거부했을 때 비밀번호 입력칸에 바로 붙일 문구.
  String? passwordErrorText;

  /// 어느 입력칸에도 붙일 수 없는 화면 단위 오류(409 중복, 그 외 400 등). 화면이 한 번만 꺼내 Snackbar로 보여준다.
  String? snackbarMessage;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  /// 비밀번호를 고치면 서버가 내려준 비밀번호 오류를 지운다. (로컬 validator는 Form이 계속 돌린다)
  void onPasswordChanged() {
    if (passwordErrorText == null) return;
    passwordErrorText = null;
    _notify();
  }

  /// 화면이 Snackbar를 띄운 뒤 호출해 같은 메시지가 다시 뜨지 않게 한다.
  void consumeSnackbarMessage() {
    snackbarMessage = null;
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (isSubmitting) return; // 연속 탭 방지
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    _notify();

    try {
      final response = await _service.signUp(request);
      if (_disposed) return;
      final id = response.result?.memberId;
      if (id == null) throw StateError('회원가입 결과에 memberId가 없습니다.');
      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      final status = error.response?.statusCode;
      final message = writeSignUpErrorMessage(error);
      debugPrint('회원가입 실패: $status $message');
      if (status == 400 && message.contains('비밀번호')) {
        // 비밀번호 형식 위반으로 확인된 400만 필드 단위 오류로 보여준다.
        passwordErrorText = message;
      } else {
        // 그 외 400과 409(최종 중복)는 화면 단위 오류.
        snackbarMessage = message;
        if (status == 409) {
          // 중복 확인 직후에도 다른 사용자가 같은 값을 등록할 수 있다.
          // 가입 시점의 409가 최종 중복 결과이므로 이전 확인 결과를 무효화해 다시 확인하게 한다.
          _nickname.invalidate();
          _email.invalidate();
        }
      }
    } on StateError catch (error) {
      if (_disposed) return;
      debugPrint('회원가입 응답 계약 오류: $error');
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    }
    _notify();
  }

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
      field.status != CheckStatus.checking &&
      field.current.isNotEmpty &&
      !isSubmitting;

  /// 입력이 바뀌면 이전 확인 결과와, 제출로 받은 서버 오류를 함께 무효화한다.
  void _onChanged(_CheckField field, String value) {
    final trimmed = value.trim();
    if (trimmed == field.current) return; // 앞뒤 공백만 바뀐 경우는 결과 유지
    field.current = trimmed;
    field.invalidate();
    if (submitStatus == SubmitStatus.error) {
      submitStatus = SubmitStatus.idle;
      snackbarMessage = null;
    }
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
