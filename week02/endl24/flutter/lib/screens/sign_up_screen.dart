import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/sign_up_header.dart';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SignUpHeader(),
                Text('닉네임'),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: '닉네임을 입력해주세요',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    final nickname = value?.trim() ?? '';
                    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
                    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                ),
                Text('이메일'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: '이메일을 입력해주세요',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return '이메일을 입력해주세요.';
                    if (!_emailRegExp.hasMatch(email)) {
                      return '올바른 이메일 형식이 아닙니다.';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                  focusNode: _emailFocusNode,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                Text('비밀번호'),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                    ),
                    const Text('필수 약관에 동의합니다'),
                  ],
                ),
                ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.violet,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.violetLight,
                    disabledForegroundColor: AppColors.white,
                  ),
                  child: const Text('가입하기'),
                ),
              ],
            ),
          ),
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
