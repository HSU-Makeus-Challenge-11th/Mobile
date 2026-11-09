import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/movie_log_button.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
    this.isLoading = false,
  });

  final bool canSubmit;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          height: 48,
          disabledBackgroundColor: AppColors.secondary300,
          buttonKey: const Key('sign-up-submit-button'),
          isLoading: isLoading,
          onPressed: canSubmit ? onSubmit : null,
        ),
        const SizedBox(height: AppSpacing.x2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이미 계정이 있나요?', style: AppTextStyles.signUpIntro),
            TextButton(onPressed: () {}, child: const Text('로그인')),
          ],
        ),
      ],
    );
  }
}
