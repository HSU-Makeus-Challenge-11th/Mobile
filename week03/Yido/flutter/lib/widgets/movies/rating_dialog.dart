import 'package:flutter/material.dart';
import 'package:movielog/widgets/movies/movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.onSaved});
  final ValueChanged<double> onSaved;
  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0;
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFFFAF9F5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    child: SizedBox(
      width: 342,
      height: 212,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          children: [
            const Text(
              '영화는 어떠셨나요?',
              style: TextStyle(
                fontSize: 20,
                height: 27 / 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25232A),
              ),
            ),
            const SizedBox(height: 25),
            MovieRatingInput(
              rating: rating,
              onChanged: (v) => setState(() => rating = v),
            ),
            const Spacer(),
            SizedBox(
              width: 294,
              height: 48,
              child: FilledButton(
                key: const Key('confirmRatingButton'),
                onPressed: rating == 0
                    ? null
                    : () {
                        widget.onSaved(rating);
                        Navigator.pop(context);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
    ),
  );
}
