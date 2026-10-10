import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/widgets/common_app_bar.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  double? _savedRating;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CommonAppBar(
      title: '별점 남기기',
      centerTitle: true,
      onBack: () => Navigator.of(context).pop(),
    ),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('이 영화는 어떠셨나요?', style: AppTextStyles.titleLarge),
              const SizedBox(height: 24),
              Semantics(
                label: '영화 별점',
                value: _rating.toStringAsFixed(1),
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 0,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 42,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 3),
                  itemBuilder: (_, _) => const Icon(
                    Icons.star_rounded,
                    color: AppColors.tertiary300,
                  ),
                  onRatingUpdate: (value) => setState(() => _rating = value),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '선택한 별점: ${_rating.toStringAsFixed(1)}점',
                style: AppTextStyles.bodyLarge,
              ),
              if (_savedRating != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '로컬 연습으로 ${_savedRating!.toStringAsFixed(1)}점을 저장했습니다.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              const SizedBox(height: 28),
              ElevatedButton(
                key: const Key('saveRatingButton'),
                onPressed: _rating > 0
                    ? () {
                        setState(() => _savedRating = _rating);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${_rating.toStringAsFixed(1)}점이 로컬로 저장되었습니다.',
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 52),
                  backgroundColor: AppColors.primary500,
                  disabledBackgroundColor: AppColors.primary200,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
