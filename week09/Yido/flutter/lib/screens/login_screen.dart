import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 로그인 기본·요청 중·실패 (W8-03, W8-04, W8-05).
/// 화면 이동은 하지 않는다. 상태가 바뀌면 Router가 보낸다
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthViewModel _auth;
  String? _emailError;
  String? _passwordError;

  static const _error = Color(0xFFB3261E);

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);
    // 이미 만료된 상태로 화면이 처음 열린 경우도 안내한다
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
  }

  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired(); // 같은 안내가 반복되지 않게 먼저 끈다
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')));
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.isEmpty ? '이메일을 입력해 주세요.' : null;
      _passwordError = _password.text.isEmpty ? '비밀번호를 입력해 주세요.' : null;
    });
    if (_emailError != null || _passwordError != null) return;
    FocusScope.of(context).unfocus();
    _auth.login(email, _password.text); // 비밀번호는 저장하지 않는다
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  Widget _label(String text) => Text(
    text,
    strutStyle: w8Strut(14),
    style: w8Text(14, FontWeight.w600, AppColors.mutedText),
  );

  Widget _errorText(String? text) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8.64),
          child: Text(
            text,
            strutStyle: w8Strut(12),
            style: w8Text(12, FontWeight.w500, _error),
          ),
        );

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required bool enabled,
    required bool invalid,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
  }) {
    final border = _border(invalid ? _error : AppColors.cardBorder);
    return SizedBox(
      height: 48,
      child: TextField(
        key: key,
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: action,
        onSubmitted: onSubmitted,
        onChanged: (_) {
          if (_emailError != null || _passwordError != null) {
            setState(() => _emailError = _passwordError = null);
          }
        },
        style: w8Text(14, FontWeight.w500, AppColors.ink),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: border,
          enabledBorder: border,
          disabledBorder: border, // 요청 중에도 모양은 그대로 둔다 (W8-04)
          focusedBorder: _border(invalid ? _error : AppColors.primary500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress;
    // 서버 응답 문구는 비밀번호 칸 아래 한 곳에 보여 준다 (W8-05)
    final serverMessage = auth.status == AuthStatus.signedOut
        ? auth.message
        : null;
    final passwordMessage = _passwordError ?? serverMessage;

    return Scaffold(
      backgroundColor: AppColors.surfaceBright,
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surfaceBright,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '로그인',
          strutStyle: w8Strut(20),
          style: w8Text(20, FontWeight.w700, AppColors.primary500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 89),
            Center(
              child: SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 60,
                height: 48,
                semanticsLabel: 'MovieLog 로고',
              ),
            ),
            const SizedBox(height: 26.28),
            Text(
              'MovieLog에 로그인',
              textAlign: TextAlign.center,
              strutStyle: w8Strut(24),
              style: w8Text(24, FontWeight.w700, AppColors.ink),
            ),
            const SizedBox(height: 31.3),
            _label('이메일'),
            const SizedBox(height: 6.42),
            _field(
              key: const Key('loginEmailField'),
              controller: _email,
              enabled: enabled,
              invalid: _emailError != null,
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
            ),
            // 이메일 오류는 다음 라벨 사이 간격 안에 들어가 화면이 밀리지 않는다
            SizedBox(
              height: 24.58,
              child: Align(
                alignment: Alignment.topLeft,
                child: _errorText(_emailError),
              ),
            ),
            _label('비밀번호'),
            const SizedBox(height: 6.42),
            _field(
              key: const Key('loginPasswordField'),
              controller: _password,
              enabled: enabled,
              invalid: passwordMessage != null,
              obscure: true,
              action: TextInputAction.done,
              onSubmitted: (_) => enabled ? _submit() : null,
            ),
            SizedBox(
              height: 112,
              child: Align(
                alignment: Alignment.topLeft,
                child: _errorText(passwordMessage),
              ),
            ),
            MovieLogButton(
              key: const Key('loginButton'),
              label: '로그인',
              width: double.infinity,
              isLoading: loading,
              labelStyle: w8Text(14, FontWeight.w700, AppColors.white),
              onPressed: enabled ? _submit : null,
            ),
            const SizedBox(height: 21.58),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '계정이 없나요?',
                  strutStyle: w8Strut(14),
                  style: w8Text(14, FontWeight.w500, AppColors.mutedText),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  key: const Key('goSignUpButton'),
                  onTap: enabled ? () => context.push('/register') : null,
                  child: Text(
                    '회원가입',
                    strutStyle: w8Strut(14),
                    style: w8Text(14, FontWeight.w700, AppColors.primary500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
