import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class MyRatingsEntry extends StatelessWidget {
  const MyRatingsEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('my-ratings-entry'),
      margin: const EdgeInsets.only(top: AppSpacing.x3, bottom: AppSpacing.x4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.medium,
        border: Border.all(color: const Color(0xFFD6C9E8), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
        minTileHeight: 64,
        title: const Text('내가 등록한 평점', style: AppTextStyles.bodyLargeBold),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: () => context.push('/my/ratings'),
      ),
    );
  }
}
