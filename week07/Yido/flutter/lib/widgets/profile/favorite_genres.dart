import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 선호하는 장르 제목과 장르 Chip 목록.
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key, required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          '선호하는 장르',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 17,
            height: 23 / 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Wrap(
          spacing: 8,
          children: genres.map((genre) {
            final width = switch (genre) {
              '드라마' => 69.0,
              'SF' => 49.0,
              _ => 88.0,
            };
            return SizedBox(
              width: width,
              height: 33,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFEADCFD),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    genre,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
