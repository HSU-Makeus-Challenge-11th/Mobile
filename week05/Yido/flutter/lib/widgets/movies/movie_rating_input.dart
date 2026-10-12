import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });
  final double rating;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '영화 별점',
    value: rating.toStringAsFixed(1),
    child: RatingBar.builder(
      initialRating: rating,
      minRating: 0,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 40,
      unratedColor: const Color(0xFFD9D3DF),
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, index) =>
          const Icon(Icons.star_rounded, color: Color(0xFF6750A4)),
      onRatingUpdate: onChanged,
    ),
  );
}
