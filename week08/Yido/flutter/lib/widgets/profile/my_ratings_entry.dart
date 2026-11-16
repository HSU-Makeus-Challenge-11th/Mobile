import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class MyRatingsEntry extends StatelessWidget {
  const MyRatingsEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        minTileHeight: 64,
        contentPadding: const EdgeInsets.fromLTRB(19, 0, 18, 0),
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD6C9E8), width: 1.5),
        ),
        title: Text(
          '내가 등록한 평점',
          style: AppTextStyles.bodyLarge.copyWith(
            height: 22 / 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        trailing: const CustomPaint(
          size: Size(8, 14),
          painter: _ChevronPainter(),
        ),
        onTap: () => context.push('/my/ratings'),
      ),
    );
  }
}

/// W6-ENTRY의 오른쪽 화살표: 8x14, 선 굵기 2.5
class _ChevronPainter extends CustomPainter {
  const _ChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => false;
}
