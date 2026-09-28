import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      SizedBox(
        height: 48,
        child: Center(
          child: Text(
            '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF494551),
            ),
          ),
        ),
      ),
      SizedBox(height: 16),
    ],
  );
}
