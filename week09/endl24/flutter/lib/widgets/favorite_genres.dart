import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// '선호하는 장르' 제목(+ SVG 아이콘)과 장르 Chip 목록을 보여준다.
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key, required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/movie.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.violet,
                BlendMode.srcIn,
              ),
              semanticsLabel: '장르 아이콘',
            ),
            const SizedBox(width: 8),
            Text('선호하는 장르', style: AppTextStyles.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres
              .map(
                (genre) => Chip(
                  label: Text(
                    genre,
                    style: const TextStyle(color: AppColors.violetDark),
                  ),
                  backgroundColor: AppColors.violetLight,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
