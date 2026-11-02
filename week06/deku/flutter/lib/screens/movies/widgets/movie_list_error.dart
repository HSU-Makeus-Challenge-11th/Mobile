import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class MovieListError extends StatelessWidget {
  const MovieListError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('movie-list-error'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.x2),
            const Text('영화를 불러오지 못했어요', style: AppTextStyles.bodyLargeSemiBold),
            const SizedBox(height: AppSpacing.x1),
            const Text(
              '잠시 후 다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray),
            ),
            const SizedBox(height: AppSpacing.x3),
            FilledButton.icon(
              key: const Key('movie-list-retry-button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
