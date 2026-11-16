import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';

/// 평점 입력 별 5개.
///
/// v6 평점 score는 1~5 사이 **정수**라서 반 점 입력을 허용하지 않는다(allowHalfRating: false).
/// 3주차의 반 점 값을 조용히 toInt()로 버리지 않고, 처음부터 별 한 개 단위로만 탭하게 막는다.
/// RatingBar는 항상 double을 돌려주므로 [rating]/[onChanged] 타입은 그대로 double이고,
/// 선택된 값은 1.0, 2.0처럼 정수를 나타내는 double로 전달된다.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;

  /// 저장 중에는 false로 두어 별을 바꾸지 못하게 한다.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      allowHalfRating: false,
      ignoreGestures: !enabled,
      glow: false,
      itemCount: 5,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      unratedColor: const Color(0xFFD9D3DF),
      itemBuilder: (context, index) {
        return const Icon(Icons.star_rounded, color: AppColors.primary500);
      },
      onRatingUpdate: onChanged,
    );
  }
}
