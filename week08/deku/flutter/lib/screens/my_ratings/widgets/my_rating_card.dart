import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';
import '../../../view_models/my_ratings_view_model.dart';
import '../../../widgets/tmdb_poster_image.dart';

class MyRatingCard extends StatelessWidget {
  const MyRatingCard({
    super.key,
    required this.item,
    this.isEditing = false,
    this.isSelected = false,
    this.onSelected,
    this.onEdit,
    this.onDelete,
  });

  final MyRatingItem item;
  final bool isEditing;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final rating = item.rating;
    final movie = item.movie;
    return InkWell(
      onTap: isEditing ? () => onSelected?.call(!isSelected) : null,
      borderRadius: AppRadius.medium,
      child: Container(
        key: ValueKey('my-rating-${rating.ratingId}'),
        height: isEditing ? 128 : 156,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.medium,
          border: Border.all(color: const Color(0xFFD9D3E1), width: 1.5),
        ),
        child: isEditing
            ? Row(
                children: [
                  Checkbox(
                    key: ValueKey('select-rating-${rating.ratingId}'),
                    value: isSelected,
                    activeColor: AppColors.primary,
                    onChanged: (value) => onSelected?.call(value ?? false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${movie.title} · 별점 ${rating.score}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          rating.displayComment,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMediumRegular.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF655F6C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 82,
                    height: 124,
                    child: ClipRRect(
                      borderRadius: AppRadius.medium,
                      child: TmdbPosterImage(movie: movie),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '별점 ${rating.score} / 5',
                          style: AppTextStyles.labelLargeBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          rating.displayComment,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMediumRegular.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF655F6C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        key: ValueKey('edit-rating-${rating.ratingId}'),
                        label: '수정',
                        background: const Color(0xFFF0EAF8),
                        foreground: AppColors.primary,
                        onPressed: onEdit,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        key: ValueKey('delete-rating-${rating.ratingId}'),
                        label: '삭제',
                        background: const Color(0xFFFFF2F0),
                        foreground: AppColors.error,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 58,
    height: 34,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
