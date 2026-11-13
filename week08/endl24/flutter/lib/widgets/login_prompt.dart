import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 회원가입 화면 하단의 로그인 안내. 회원가입은 로그인 화면에서 push로 열리므로 닫아서 돌아갑니다.
class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있나요?',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grayDark),
        ),
        TextButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/login'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.violet,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('로그인'),
        ),
      ],
    );
  }
}
