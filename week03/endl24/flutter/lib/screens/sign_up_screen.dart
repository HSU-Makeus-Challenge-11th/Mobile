import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/login_prompt.dart';
import 'package:movielog/widgets/movie_log_text_form_field.dart';
import 'package:movielog/widgets/sign_up_header.dart';
import 'package:movielog/widgets/terms_agreement.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _agreedToTerms = false;
  final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '회원가입',
        centerTitle: true,
        onBack: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 560 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SignUpHeader(),
                        const SizedBox(height: 40),
                        MovieLogTextFormField(
                          label: '닉네임',
                          hintText: '닉네임을 입력해주세요',
                          controller: _nicknameController,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final nickname = value?.trim() ?? '';
                            if (nickname.isEmpty) return '닉네임을 입력해주세요.';
                            if (nickname.length < 2) {
                              return '닉네임은 2자 이상이어야 합니다.';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) =>
                              _emailFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 20),
                        MovieLogTextFormField(
                          label: '이메일',
                          hintText: '이메일을 입력해주세요',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) return '이메일을 입력해주세요.';
                            if (!_emailRegExp.hasMatch(email)) {
                              return '올바른 이메일 형식이 아닙니다.';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) =>
                              _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 20),
                        MovieLogTextFormField(
                          label: '비밀번호',
                          hintText: '비밀번호를 입력해주세요',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          validator: (value) {
                            final password = value ?? '';
                            if (password.isEmpty) return '비밀번호를 입력해주세요.';
                            if (!_passwordRegExp.hasMatch(password)) {
                              return '영문과 숫자를 포함해 8자 이상 입력해주세요.';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 48),
                        TermsAgreement(
                          value: _agreedToTerms,
                          onChanged: (value) =>
                              setState(() => _agreedToTerms = value),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppColors.violet,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.violetMuted,
                            disabledForegroundColor: AppColors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('가입하기'),
                        ),
                        const SizedBox(height: 32),
                        const LoginPrompt(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _nicknameController.text.trim().length >= 2 &&
      _emailRegExp.hasMatch(_emailController.text.trim()) &&
      _passwordRegExp.hasMatch(_passwordController.text) &&
      _agreedToTerms;
  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다.')));
    context.go('/home');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
