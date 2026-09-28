import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import 'widgets/movie_log_text_form_field.dart';
import 'widgets/sign_up_app_bar.dart';
import 'widgets/sign_up_footer.dart';
import 'widgets/sign_up_intro.dart';
import 'widgets/terms_agreement.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

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

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool get _isNicknameValid => _nicknameController.text.trim().length >= 2;
  bool get _isEmailValid =>
      _emailPattern.hasMatch(_emailController.text.trim());
  bool get _isPasswordValid => _passwordController.text.length >= 8;
  bool get _canSubmit =>
      _isNicknameValid && _isEmailValid && _isPasswordValid && _agreedToTerms;

  @override
  void dispose() {
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
    return null;
  }

  void _onNicknameChanged(String _) {
    setState(() => _nicknameTouched = true);
  }

  void _onEmailChanged(String _) {
    setState(() => _emailTouched = true);
  }

  void _onPasswordChanged(String _) {
    setState(() => _passwordTouched = true);
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_agreedToTerms) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('입력값 검증이 완료되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      validationState: _nicknameController.text.isEmpty
                          ? FieldValidationState.none
                          : _nicknameTouched && !_isNicknameValid
                          ? FieldValidationState.invalid
                          : FieldValidationState.valid,
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
                      validationState: _emailController.text.isEmpty
                          ? FieldValidationState.none
                          : _emailTouched && !_isEmailValid
                          ? FieldValidationState.invalid
                          : FieldValidationState.valid,
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
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      validationState: _passwordController.text.isEmpty
                          ? FieldValidationState.none
                          : _passwordTouched && !_isPasswordValid
                          ? FieldValidationState.invalid
                          : FieldValidationState.valid,
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
                    SignUpFooter(canSubmit: _canSubmit, onSubmit: _submit),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
