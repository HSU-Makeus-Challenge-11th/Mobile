import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 라벨과 숫자를 보여주는 통계 카드. 데이터만 바꿔 재사용한다.
class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.only(top: 19),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        border: Border.all(color: const Color(0xFFE4DAF1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              strutStyle: const StrutStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                height: 16 / 12,
                forceStrutHeight: true,
              ),
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 31,
            child: Text(
              value,
              maxLines: 1,
              strutStyle: const StrutStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 23,
                height: 31 / 23,
                forceStrutHeight: true,
              ),
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 23,
                height: 31 / 23,
                fontWeight: FontWeight.w700,
                color: AppColors.primary500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
