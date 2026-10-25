import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
  });

  final bool canSubmit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton(
            key: const Key('sign-up-submit-button'),
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.secondary300,
              disabledForegroundColor: AppColors.white,
              textStyle: AppTextStyles.signUpButton,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.medium,
              ),
            ),
            child: const Text('가입하기'),
          ),
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
