import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movie_log_text_form_field.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 로그인 화면은 AuthViewModel.login()만 호출합니다.
/// 성공 후 홈 이동은 화면이 아니라 Router(redirect)가 맡습니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthViewModel>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress;

    return Scaffold(
      appBar: const CommonAppBar(title: '로그인', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                SvgPicture.asset(
                  'assets/logos/movielog_logo.svg',
                  width: 56,
                  height: 56,
                  semanticsLabel: 'MovieLog 로고',
                ),
                const SizedBox(height: 16),
                Text(
                  'MovieLog에 로그인',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 40),
                MovieLogTextFormField(
                  label: '이메일',
                  hintText: 'movie@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? '이메일을 입력해 주세요.' : null,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 20),
                MovieLogTextFormField(
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해 주세요',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? '비밀번호를 입력해 주세요.' : null,
                  // 로그인 실패 문구는 비밀번호 칸 아래에 보여줍니다.
                  errorText: auth.status == AuthStatus.signedOut
                      ? auth.message
                      : null,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) {
                    if (enabled) _submit();
                  },
                ),
                const SizedBox(height: 48),
                MovieLogButton(
                  label: '로그인',
                  width: double.infinity,
                  height: 52,
                  isLoading: loading,
                  onPressed: enabled ? _submit : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없나요?',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grayDark,
                      ),
                    ),
                    TextButton(
                      onPressed: enabled ? () => context.push('/signup') : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.violet,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
