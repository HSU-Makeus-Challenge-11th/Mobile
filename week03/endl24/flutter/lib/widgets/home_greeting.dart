import 'package:flutter/widgets.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '오늘은 어떤\n영화를 볼까요?',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 36 / 28,
        letterSpacing: -0.7,
        color: Color(0xFF1D1B20),
      ),
    );
  }
}
