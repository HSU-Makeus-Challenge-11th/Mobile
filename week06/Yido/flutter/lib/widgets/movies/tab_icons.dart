import 'package:flutter/material.dart';

/// W6-ENTRY 하단 탭 아이콘. 선 굵기와 크기는 프레임 값을 따른다
enum TabIconShape { home, movie, my }

class TabIcon extends StatelessWidget {
  const TabIcon({super.key, required this.shape, required this.color});

  final TabIconShape shape;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: switch (shape) {
      TabIconShape.home => const Size(16, 18),
      TabIconShape.movie => const Size(17, 17),
      TabIconShape.my => const Size(18, 17),
    },
    painter: _TabIconPainter(shape, color),
  );
}

class _TabIconPainter extends CustomPainter {
  const _TabIconPainter(this.shape, this.color);

  final TabIconShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    switch (shape) {
      case TabIconShape.home:
        canvas.drawPath(
          Path()
            ..moveTo(0.8, 5.6)
            ..lineTo(8, 0.9)
            ..lineTo(15.2, 5.6)
            ..lineTo(15.2, 17.2)
            ..lineTo(0.8, 17.2)
            ..close(),
          line,
        );
      case TabIconShape.movie:
        canvas.drawRect(const Rect.fromLTRB(0.8, 2.7, 16.2, 16.2), line);
        canvas.drawLine(const Offset(4.5, 0), const Offset(4.5, 2.7), line);
        canvas.drawLine(const Offset(11.7, 0), const Offset(11.7, 2.7), line);
      case TabIconShape.my:
        canvas.drawCircle(const Offset(9, 4), 4, Paint()..color = color);
        canvas.drawPath(
          Path()
            ..moveTo(1, 16.9)
            ..quadraticBezierTo(9, 11.1, 17, 16.9),
          line..strokeWidth = 2,
        );
    }
  }

  @override
  bool shouldRepaint(_TabIconPainter oldDelegate) =>
      shape != oldDelegate.shape || color != oldDelegate.color;
}
