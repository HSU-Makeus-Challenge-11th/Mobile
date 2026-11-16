import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

/// W6 프레임의 뒤로가기 화살표: 15x14, 2px 선
class BackArrowIcon extends StatelessWidget {
  const BackArrowIcon({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(size: Size(15, 14), painter: _BackArrowPainter());
}

class _BackArrowPainter extends CustomPainter {
  const _BackArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height / 2)
        ..lineTo(0, size.height / 2)
        ..moveTo(7, 0)
        ..lineTo(0, size.height / 2)
        ..lineTo(7, size.height),
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BackArrowPainter oldDelegate) => false;
}
