import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.movieTitle});

  final String movieTitle;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '평점 남기기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.movieTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.gray),
            ),
            const SizedBox(height: 24),
            MovieRatingInput(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 16),
            Text(
              _rating == 0 ? '별을 눌러 평점을 선택해주세요' : '$_rating / 5.0',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _rating == 0 ? AppColors.gray : AppColors.violet,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AppColors.gray,
                      side: const BorderSide(color: AppColors.grayLine),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _rating == 0
                        ? null
                        : () => Navigator.pop(context, _rating),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.violet,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.violetMuted,
                      disabledForegroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}