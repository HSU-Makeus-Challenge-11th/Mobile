import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'movie_rating_input.dart';

/// 평점 입력 Dialog. 확인을 누르면 선택한 평점을 `Navigator.pop`으로 돌려준다.
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, this.initialRating = 0});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double rating = widget.initialRating;

  // RatingBar는 initialRating을 처음 한 번만 읽으므로,
  // "다시 선택하기" 때 key를 바꿔 별을 새로 그리게 한다.
  int _resetCount = 0;

  void _reset() {
    setState(() {
      rating = 0;
      _resetCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasRating = rating > 0;

    return Dialog(
      backgroundColor: AppColors.surfaceBase,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영화는 어떠셨나요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                height: 27 / 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25232A),
              ),
            ),
            const SizedBox(height: 24),
            MovieRatingInput(
              key: ValueKey(_resetCount),
              rating: rating,
              onChanged: (value) => setState(() => rating = value),
            ),
            // 평점을 고른 뒤에만 보이는 "다시 선택하기"
            if (hasRating) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _reset,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary500,
                ),
                child: const Text(
                  '다시 선택하기',
                  style: TextStyle(
                    fontSize: 14,
                    height: 19 / 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: hasRating
                    ? () => Navigator.pop(context, rating)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.secondary300,
                  disabledForegroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
