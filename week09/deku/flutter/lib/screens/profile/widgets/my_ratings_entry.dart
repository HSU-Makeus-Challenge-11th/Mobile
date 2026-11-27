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
      margin: const EdgeInsets.only(top: AppSpacing.x4, bottom: AppSpacing.x2),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minTileHeight: 48,
        title: const Text('내가 등록한 평점', style: AppTextStyles.bodyMediumRegular),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.profileOnSurface,
        ),
        onTap: () => context.push('/my/ratings'),
      ),
    );
  }
}
