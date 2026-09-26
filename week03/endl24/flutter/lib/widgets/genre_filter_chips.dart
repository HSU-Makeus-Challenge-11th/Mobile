import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

class GenreFilterChips extends StatelessWidget {
  const GenreFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  final List<String> genres;
  final String selectedGenre;
  final ValueChanged<String> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final genre in genres) ...[
            ChoiceChip(
              label: Text(genre),
              selected: genre == selectedGenre,
              onSelected: (_) => onGenreSelected(genre),
              showCheckmark: false,
              backgroundColor: AppColors.violetLight,
              selectedColor: AppColors.violet,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: genre == selectedGenre
                    ? AppColors.white
                    : AppColors.grayDark,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
