import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.primary500),
        SizedBox(height: 16),
        Text('영화를 불러오는 중입니다', style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.movie_outlined, size: 48, color: AppColors.textSecondary),
        SizedBox(height: 12),
        Text('조건에 맞는 영화가 없습니다.', style: AppTextStyles.bodyLarge),
      ],
    ),
  );
}

class MovieListError extends StatelessWidget {
  const MovieListError({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        const Text('영화를 불러오지 못했습니다.', style: AppTextStyles.bodyLarge),
        const SizedBox(height: 4),
        const Text('잠시 후 다시 시도해 주세요.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('retryButton'),
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary500,
          ),
          child: const Text('다시 시도'),
        ),
      ],
    ),
  );
}
