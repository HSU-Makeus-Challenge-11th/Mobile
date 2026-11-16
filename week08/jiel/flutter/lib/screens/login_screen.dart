import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';

/// 로그인 화면(Required). 이메일 저장 체크박스는 Challenge 범위라 넣지 않았다.
///
/// 버튼은 AuthViewModel.login()만 호출하고 직접 /home으로 이동하지 않는다.
/// 성공 → signedIn → Router가 /home, 실패 → signedOut + message로 Form 아래 오류 표시.
/// 세션 만료로 이 화면에 왔을 때만 Snackbar로 안내한다(직접 로그아웃·로그인 실패는 제외).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);
    // 이미 만료된 상태로 화면이 처음 열리는 경우도 처리한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
  }

  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired(); // 먼저 꺼서 같은 Snackbar가 반복되지 않게 한다.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')),
      );
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _auth.login(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          '로그인',
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: SvgPicture.asset(
                  'assets/logos/movielog_Icon.svg',
                  width: 60,
                  height: 48,
                  semanticsLabel: 'MovieLog 로고',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'MovieLog에 로그인',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _email,
                enabled: enabled,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: '이메일'),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? '이메일을 입력해 주세요.' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _password,
                enabled: enabled,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (enabled) _submit();
                },
                decoration: const InputDecoration(labelText: '비밀번호'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? '비밀번호를 입력해 주세요.' : null,
              ),
              if (auth.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    auth.message!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
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
              TextButton(
                onPressed: enabled ? () => context.push('/register') : null,
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
