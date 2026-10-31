import 'package:flutter/material.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';

class MyRatingCard extends StatelessWidget {
  const MyRatingCard({super.key, required this.entry});

  static const _posterWidth = 82.0;
  static const _posterHeight = 124.0;
  static const _placeholderColor = Color(0xFFD8D2E0);

  static const _bodyStyle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
  );

  final RatingWithMovie entry;

  String get _createdDate {
    final date = entry.rating.createdAt.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie;
    final posterPath = movie?.posterPath;
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: posterPath == null
                ? Container(
                    width: _posterWidth,
                    height: _posterHeight,
                    color: _placeholderColor,
                  )
                : TmdbPosterImage(
                    posterPath: posterPath,
                    width: _posterWidth,
                    height: _posterHeight,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie?.title ?? '영화 #${rating.movieId}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 17,
                      height: 23 / 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '별점 ${rating.score} / 5',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 14,
                      height: 19 / 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary500,
                    ),
                  ),
                  if (posterPath == null) ...[
                    const SizedBox(height: 12),
                    const Text('포스터 정보 없음', style: _bodyStyle),
                  ],
                  if (comment != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      comment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _bodyStyle,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _createdDate,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
