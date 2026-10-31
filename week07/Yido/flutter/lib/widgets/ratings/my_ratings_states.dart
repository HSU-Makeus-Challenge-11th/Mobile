import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/widgets/movielog_button.dart';

class MyRatingsLoading extends StatelessWidget {
  const MyRatingsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          CircularProgressIndicator(),
          Text('평점을 불러오는 중', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class MyRatingsEmpty extends StatelessWidget {
  const MyRatingsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('등록된 평점이 없습니다', style: AppTextStyles.bodyMedium),
    );
  }
}

class MyRatingsError extends StatelessWidget {
  const MyRatingsError({super.key, this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message ?? '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            MovieLogButton(
              key: const Key('ratingsRetryButton'),
              label: '다시 시도',
              width: 120,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
