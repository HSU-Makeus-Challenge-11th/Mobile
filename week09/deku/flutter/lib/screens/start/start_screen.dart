import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/movie_log_logo.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  static const routeName = '/start';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MovieLogLogo(),
                const SizedBox(height: 32),
                if (auth.status == AuthStatus.retryRequired) ...[
                  Text(
                    auth.message ?? '로그인 상태를 확인하지 못했어요.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('session-retry-button'),
                    onPressed: auth.restoreSession,
                    child: const Text('다시 시도'),
                  ),
                ] else ...[
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text('로그인 상태를 확인하고 있어요.'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
