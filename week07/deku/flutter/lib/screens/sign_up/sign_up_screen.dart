import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/create_member_request.dart';
import '../../data/services/member_check_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../view_models/sign_up_view_model.dart';
import '../../view_models/learning_member_session.dart';
import '../../widgets/movie_log_button.dart';
import 'widgets/movie_log_text_form_field.dart';
import 'widgets/sign_up_app_bar.dart';
import 'widgets/sign_up_footer.dart';
import 'widgets/sign_up_intro.dart';
import 'widgets/terms_agreement.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/register';
  const SignUpScreen({super.key, this.memberCheckService});

  final MemberCheckService? memberCheckService;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _nicknameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  late final SignUpViewModel _viewModel;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool get _isNicknameValid {
    final length = _nicknameController.text.trim().length;
    return length >= 2 && length <= 12;
  }

  bool get _isEmailValid =>
      _emailPattern.hasMatch(_emailController.text.trim());
  bool get _isPasswordValid =>
      _passwordPattern.hasMatch(_passwordController.text);
  static final _passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$',
  );
  bool get _canSubmit =>
      _isNicknameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _agreedToTerms &&
      _viewModel.nicknameCheckStatus == MemberCheckStatus.available &&
      _viewModel.emailCheckStatus == MemberCheckStatus.available &&
      _viewModel.submitStatus != SubmitStatus.submitting;

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel(
      widget.memberCheckService ?? MemberCheckService(Dio()),
    )..addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    if (nickname.length > 12) return '닉네임은 12자 이하여야 합니다.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return '이메일 주소를 입력해주세요.';
    if (!_emailPattern.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return '비밀번호를 입력해주세요.';
    if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    if (!_passwordPattern.hasMatch(password)) {
      return '8자 이상, 대소문자·숫자·특수문자를 모두 포함해 주세요.';
    }
    return null;
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _onNicknameChanged(String value) {
    _nicknameTouched = true;
    _viewModel.onNicknameChanged(value);
  }

  void _onEmailChanged(String value) {
    _emailTouched = true;
    _viewModel.onEmailChanged(value);
  }

  void _onPasswordChanged(String _) {
    setState(() => _passwordTouched = true);
    _viewModel.onPasswordChanged();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_agreedToTerms) return;

    FocusScope.of(context).unfocus();
    await _viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return;
    if (_viewModel.submitStatus == SubmitStatus.success &&
        _viewModel.createdMemberId != null) {
      context.read<LearningMemberSession>().setMemberId(
        _viewModel.createdMemberId!,
      );
      context.go('/movies');
      return;
    }
    final message = _viewModel.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _viewModel.submitStatus != SubmitStatus.submitting,
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: const SignUpAppBar(),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                key: const Key('sign-up-scroll-view'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2,
                  AppSpacing.x3,
                  AppSpacing.x2,
                  AppSpacing.x3,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SignUpIntro(),
                      const SizedBox(height: AppSpacing.x4),
                      MovieLogTextFormField(
                        key: const Key('nickname-field'),
                        label: '닉네임',
                        hintText: '닉네임을 입력해주세요',
                        controller: _nicknameController,
                        focusNode: _nicknameFocusNode,
                        textInputAction: TextInputAction.next,
                        validator: _validateNickname,
                        onChanged: _onNicknameChanged,
                        onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                        validationState: _nicknameValidationState,
                        errorText: _viewModel.nicknameErrorText,
                        helperText: _viewModel.nicknameHelperText,
                        trailing: MovieLogButton(
                          key: const Key('nickname-check-button'),
                          label: '중복 확인',
                          width: 102,
                          isLoading:
                              _viewModel.nicknameCheckStatus ==
                              MemberCheckStatus.loading,
                          onPressed: _viewModel.canCheckNickname
                              ? () {
                                  _viewModel.checkNickname();
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      MovieLogTextFormField(
                        key: const Key('email-field'),
                        label: '이메일',
                        hintText: '이메일 주소를 입력해주세요',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                        onChanged: _onEmailChanged,
                        onFieldSubmitted: (_) =>
                            _passwordFocusNode.requestFocus(),
                        validationState: _emailValidationState,
                        errorText: _viewModel.emailErrorText,
                        helperText: _viewModel.emailHelperText,
                        trailing: MovieLogButton(
                          key: const Key('email-check-button'),
                          label: '중복 확인',
                          width: 102,
                          isLoading:
                              _viewModel.emailCheckStatus ==
                              MemberCheckStatus.loading,
                          onPressed: _viewModel.canCheckEmail
                              ? () {
                                  _viewModel.checkEmail();
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      MovieLogTextFormField(
                        key: const Key('password-field'),
                        label: '비밀번호',
                        hintText: '비밀번호를 입력해주세요',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onChanged: _onPasswordChanged,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                        validationState: _passwordController.text.isEmpty
                            ? FieldValidationState.none
                            : _passwordTouched && !_isPasswordValid
                            ? FieldValidationState.invalid
                            : FieldValidationState.valid,
                        errorText: _viewModel.passwordErrorText,
                        isPassword: true,
                        onToggleObscure: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      TermsAgreement(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() => _agreedToTerms = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      SignUpFooter(
                        canSubmit: _canSubmit,
                        isLoading:
                            _viewModel.submitStatus == SubmitStatus.submitting,
                        onSubmit: _submit,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  FieldValidationState get _nicknameValidationState {
    if (_nicknameController.text.isEmpty) return FieldValidationState.none;
    if (_nicknameTouched && !_isNicknameValid) {
      return FieldValidationState.invalid;
    }
    return switch (_viewModel.nicknameCheckStatus) {
      MemberCheckStatus.available => FieldValidationState.valid,
      MemberCheckStatus.duplicate ||
      MemberCheckStatus.failure => FieldValidationState.invalid,
      _ => FieldValidationState.none,
    };
  }

  FieldValidationState get _emailValidationState {
    if (_emailController.text.isEmpty) return FieldValidationState.none;
    if (_emailTouched && !_isEmailValid) return FieldValidationState.invalid;
    return switch (_viewModel.emailCheckStatus) {
      MemberCheckStatus.available => FieldValidationState.valid,
      MemberCheckStatus.duplicate ||
      MemberCheckStatus.failure => FieldValidationState.invalid,
      _ => FieldValidationState.none,
    };
  }
}
