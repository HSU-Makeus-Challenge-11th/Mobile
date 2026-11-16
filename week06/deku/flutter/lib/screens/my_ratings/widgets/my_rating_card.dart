import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';
import '../../../view_models/my_ratings_view_model.dart';
import '../../../widgets/tmdb_poster_image.dart';

class MyRatingCard extends StatelessWidget {
  const MyRatingCard({super.key, required this.item});

  final MyRatingItem item;

  @override
  Widget build(BuildContext context) {
    final rating = item.rating;
    final movie = item.movie;

    return Container(
      key: ValueKey('my-rating-${rating.ratingId}'),
      height: 156,
      padding: const EdgeInsets.all(AppSpacing.x2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.medium,
        border: Border.all(color: const Color(0xFFD9D3E1), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 82,
            child: ClipRRect(
              borderRadius: AppRadius.medium,
              child: TmdbPosterImage(movie: movie),
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLargeBold.copyWith(fontSize: 17),
                ),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  '별점 ${rating.score} / 5',
                  style: AppTextStyles.labelLargeBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.x1),
                Expanded(
                  child: Text(
                    rating.displayComment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMediumRegular.copyWith(
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                Text(
                  rating.displayCreatedAt,
                  style: AppTextStyles.labelSmallRegular.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
