import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common_app_bar.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '영화 평점'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.x6),
              const Icon(
                Icons.movie_outlined,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.x3),
              const Text(
                '영화는 어떠셨나요?',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMediumSemiBold,
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                '별점을 선택하고 감상 기록을 저장해보세요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.profileOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              Center(
                child: SizedBox(
                  key: const Key('movie-rating-bar'),
                  child: RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 48,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                    unratedColor: AppColors.secondary300,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: AppColors.tertiary300,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() => _rating = rating);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              Text(
                _rating == 0
                    ? '평점을 선택해주세요.'
                    : '선택한 평점: ${_rating.toStringAsFixed(1)}',
                key: const Key('selected-rating'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLargeMedium,
              ),
              const SizedBox(height: AppSpacing.x4),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  key: const Key('save-rating-button'),
                  onPressed: _rating > 0
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '평점 ${_rating.toStringAsFixed(1)}점을 저장했습니다.',
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: AppColors.secondary300,
                    disabledForegroundColor: AppColors.white,
                  ),
                  child: const Text('평점 저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
