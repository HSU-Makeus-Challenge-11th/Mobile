import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';

/// W9 마이페이지의 "내 즐겨찾기" 행: 높이 54, 1px 테두리, 오른쪽 7x12 화살표
class MyFavoritesEntry extends StatelessWidget {
  const MyFavoritesEntry({super.key, required this.enabled});

  /// 내 정보(GET me)가 준비된 뒤에만 누를 수 있다
  final bool enabled;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceBright,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.cardBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: const Key('myFavoritesEntry'),
      onTap: enabled ? () => context.push('/my/favorites') : null,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 17, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '내 즐겨찾기',
                  style: w8Text(
                    16,
                    FontWeight.w700,
                    AppColors.ink,
                  ).copyWith(height: 22 / 16),
                ),
              ),
              const CustomPaint(size: Size(7, 12), painter: _Chevron()),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Chevron extends CustomPainter {
  const _Chevron();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, size.height),
      Paint()
        ..color = AppColors.primary500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Chevron oldDelegate) => false;
}
