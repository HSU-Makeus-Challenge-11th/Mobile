import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/theme/app_colors.dart';

/// 서버 평점은 1~5 정수라 별 한 개 단위로만 고른다
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  // W7-01: 글자 별 31px을 5개 합쳐 176 폭에 놓는다
  static const _itemSize = 35.2;

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  Widget _star(String star) => Center(
    child: Text(
      star,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 31,
        height: 1,
        fontWeight: FontWeight.w700,
        color: AppColors.primary500,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    label: '영화 별점',
    value: rating.toStringAsFixed(0),
    child: SizedBox(
      height: 42,
      child: Center(
        child: RatingBar(
          initialRating: rating,
          minRating: 1,
          allowHalfRating: false,
          ignoreGestures: !enabled,
          itemCount: 5,
          itemSize: _itemSize,
          ratingWidget: RatingWidget(
            full: _star('★'),
            half: _star('★'),
            empty: _star('☆'),
          ),
          onRatingUpdate: onChanged,
        ),
      ),
    ),
  );
}
