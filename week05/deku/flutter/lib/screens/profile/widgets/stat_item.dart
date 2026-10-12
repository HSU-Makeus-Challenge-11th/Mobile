import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('stat-item-$label'),
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(AppSpacing.x2),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.large,
        border: Border.fromBorderSide(BorderSide(color: AppColors.primary200)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.profileStatLabel),
          const SizedBox(height: AppSpacing.x1),
          Text(value, style: AppTextStyles.profileStatValue),
        ],
      ),
    );
  }
}
