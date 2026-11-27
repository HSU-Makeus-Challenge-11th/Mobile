import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class MyFavoritesEntry extends StatelessWidget {
  const MyFavoritesEntry({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('my-favorites-entry'),
    contentPadding: EdgeInsets.zero,
    minTileHeight: 48,
    title: const Text('내 즐겨찾기', style: AppTextStyles.bodyMediumRegular),
    trailing: const Icon(
      Icons.chevron_right,
      color: AppColors.profileOnSurface,
    ),
    onTap: () => context.push('/my/favorites'),
  );
}
