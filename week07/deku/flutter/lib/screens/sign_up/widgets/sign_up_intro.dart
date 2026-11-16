import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class SignUpIntro extends StatelessWidget {
  const SignUpIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다! 간단한 정보만 입력하고 시작해보세요.',
      textAlign: TextAlign.center,
      style: AppTextStyles.signUpIntro,
    );
  }
}
