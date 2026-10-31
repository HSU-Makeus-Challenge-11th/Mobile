import 'package:flutter/material.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';

class MyRatingCard extends StatelessWidget {
  const MyRatingCard({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
  });

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

  /// 둘 다 null이면 수정·삭제 버튼을 보여 주지 않는다
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 9, right: 1),
              child: Column(
                spacing: 8,
                children: [
                  _SmallButton(
                    buttonKey: Key('editRating_${rating.ratingId}'),
                    label: '수정',
                    backgroundColor: const Color(0xFFF0EAF8),
                    foregroundColor: AppColors.primary500,
                    onPressed: onEdit,
                  ),
                  _SmallButton(
                    buttonKey: Key('deleteRating_${rating.ratingId}'),
                    label: '삭제',
                    backgroundColor: const Color(0xFFFFF2F0),
                    foregroundColor: AppColors.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// W7 카드 오른쪽 버튼: 63x35, 13/18
class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.buttonKey,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => MovieLogButton(
    key: buttonKey,
    label: label,
    width: 63,
    height: 35,
    borderRadius: 8,
    horizontalPadding: 0,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    disabledColor: backgroundColor,
    labelStyle: const TextStyle(
      fontFamily: 'Manrope',
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w700,
    ),
    onPressed: onPressed,
  );
}
