import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

/// W9 프레임의 북마크: 18x25, 2px 선. 등록 후에는 같은 모양을 채운다
class BookmarkIcon extends StatelessWidget {
  const BookmarkIcon({super.key, required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(18, 25), painter: _BookmarkPainter(filled));
}

class _BookmarkPainter extends CustomPainter {
  const _BookmarkPainter(this.filled);
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(1, 1)
      ..lineTo(w - 1, 1)
      ..lineTo(w - 1, h - 1)
      ..lineTo(w / 2, h - 7)
      ..lineTo(1, h - 1)
      ..close();
    final paint = Paint()
      ..color = AppColors.primary500
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    if (filled) canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_BookmarkPainter oldDelegate) =>
      oldDelegate.filled != filled;
}
