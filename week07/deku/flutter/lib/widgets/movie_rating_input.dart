import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.allowHalfRating = true,
    this.enabled = true,
    this.itemSize = 42,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool allowHalfRating;
  final bool enabled;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('movie-rating-input'),
      child: RatingBar.builder(
        initialRating: rating,
        minRating: allowHalfRating ? 0.5 : 1,
        allowHalfRating: allowHalfRating,
        ignoreGestures: !enabled,
        itemCount: 5,
        itemSize: itemSize,
        itemPadding: const EdgeInsets.symmetric(horizontal: 2),
        unratedColor: AppColors.secondary300,
        itemBuilder: (context, index) =>
            const Icon(Icons.star_rounded, color: AppColors.primary),
        onRatingUpdate: onChanged,
      ),
    );
  }
}
