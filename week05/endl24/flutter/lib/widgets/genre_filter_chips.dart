import 'package:flutter/material.dart';
import 'package:movielog/models/tmdb_genre_dto.dart';
import 'package:movielog/theme/app_colors.dart';

class GenreFilterChips extends StatelessWidget {
  const GenreFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.enabled,
    required this.onGenreSelected,
  });

  final List<TmdbGenreDto> genres;
  final int? selectedGenreId;
  final bool enabled;
  final ValueChanged<int?> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('전체', null),
          for (final genre in genres) _buildChip(genre.name, genre.id),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int? genreId) {
    final selected = genreId == selectedGenreId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        disabledColor: AppColors.violetLight,
        label: Text(label),
        selected: selected,
        onSelected: enabled ? (_) => onGenreSelected(genreId) : null,
        showCheckmark: false,
        backgroundColor: AppColors.violetLight,
        selectedColor: AppColors.violet,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.white : AppColors.grayDark,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}