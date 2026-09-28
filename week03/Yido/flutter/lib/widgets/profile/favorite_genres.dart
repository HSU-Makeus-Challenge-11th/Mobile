import 'package:flutter/material.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 선호하는 장르 제목과 장르 Chip 목록.
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key, required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        const Text('선호하는 장르', style: AppTextStyles.bodyLarge),
        Wrap(
          spacing: 8,
          children: genres.map((genre) {
            final width = switch (genre) {
              '드라마' => 66.0,
              'SF' => 46.0,
              _ => 88.0,
            };
            return SizedBox(
              width: width,
              height: 32,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DEF9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    genre,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: const Color(0xFF21005D),
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
