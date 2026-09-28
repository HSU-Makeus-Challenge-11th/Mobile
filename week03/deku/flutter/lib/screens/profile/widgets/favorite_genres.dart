import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  static const _genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('선호하는 장르', style: AppTextStyles.profileSectionTitle),
        const SizedBox(height: AppSpacing.x1_5),
        Wrap(
          spacing: AppSpacing.x1,
          runSpacing: AppSpacing.x1,
          children: _genres
              .map(
                (genre) => ConstrainedBox(
                  key: ValueKey('genre-chip-$genre'),
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Chip(
                    label: Text(genre),
                    labelStyle: AppTextStyles.profileChipLabel,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x1,
                    ),
                    backgroundColor: AppColors.primary200,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
