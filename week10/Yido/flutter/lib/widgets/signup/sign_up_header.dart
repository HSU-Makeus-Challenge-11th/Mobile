import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Text(
        '환영합니다!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      SizedBox(height: 3),
      Text(
        '간단한 정보만 입력하고 시작해보세요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          height: 19 / 14,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
        ),
      ),
    ],
  );
}
