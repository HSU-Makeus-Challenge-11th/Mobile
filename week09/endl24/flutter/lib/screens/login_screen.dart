import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/services/email_preference.dart';
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
  late final AuthViewModel _auth;
  final _emailPreference = EmailPreference();
  bool _rememberEmail = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    // 화면이 열려 있는 동안 세션이 만료되는 경우
    _auth.addListener(_showSessionExpired);
    // 이미 만료된 상태로 이 화면이 처음 열리는 경우(Router가 /login으로 보낸 직후)
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
    _loadSavedEmail();
  }

  /// 저장된 이메일이 있으면 이메일 칸을 채우고 체크박스를 켭니다.
  Future<void> _loadSavedEmail() async {
    try {
      final saved = await _emailPreference.read();
      if (!mounted || saved == null || saved.isEmpty) return;
      // 그사이 사용자가 직접 입력했다면 덮어쓰지 않습니다.
      if (_emailController.text.isNotEmpty) return;
      setState(() {
        _emailController.text = saved;
        _rememberEmail = true;
      });
    } catch (_) {
      // 저장소를 읽지 못해도 로그인은 그대로 할 수 있습니다.
    }
  }

  /// 만료로 로그아웃된 경우에만 한 번 안내합니다.
  /// 직접 로그아웃·로그인 실패(AUTH401_1)는 sessionExpired가 false라 띄우지 않습니다.
  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired(); // 먼저 끄고 띄워야 반복되지 않습니다.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final remember = _rememberEmail;
    await _auth.login(email, _passwordController.text);
    // 로그인에 성공했을 때만 체크 상태에 맞춰 이메일을 저장하거나 지웁니다.
    // 성공하면 Router가 화면을 바꾸므로 여기서는 context를 쓰지 않습니다.
    if (_auth.status != AuthStatus.signedIn) return;
    try {
      await _emailPreference.save(remember ? email : null);
    } catch (_) {
      // 이메일 저장 실패는 로그인 결과에 영향을 주지 않습니다.
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
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
                const SizedBox(height: 12),
                // 이메일만 기억합니다. 비밀번호와 토큰은 저장하지 않습니다.
                InkWell(
                  onTap: enabled
                      ? () => setState(() => _rememberEmail = !_rememberEmail)
                      : null,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberEmail,
                        activeColor: AppColors.violet,
                        onChanged: enabled
                            ? (value) => setState(
                                () => _rememberEmail = value ?? false,
                              )
                            : null,
                      ),
                      Text('이메일 저장', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
