import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/models/rating_request.dart';
import '../../data/services/api_error_message.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/movie_log_button.dart';
import '../../widgets/movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    required this.onSubmit,
    this.initialScore = 0,
    this.initialComment,
    this.isEditing = false,
  });

  final Future<void> Function(int score, String? comment) onSubmit;
  final int initialScore;
  final String? initialComment;
  final bool isEditing;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating = widget.initialScore.toDouble();
  late final TextEditingController _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _rating < 1) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final comment = _commentController.text.trim();
      await widget.onSubmit(
        validateServerScore(_rating),
        comment.isEmpty ? null : comment,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is StateError
              ? error.message
              : '평점을 저장하지 못했습니다. 다시 시도해 주세요.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        key: const Key('rating-dialog'),
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEditing ? '평점을 수정해주세요' : '평점을 남겨주세요',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLargeBold.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF25232A),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: MovieRatingInput(
                  rating: _rating,
                  allowHalfRating: false,
                  enabled: !_isSubmitting,
                  itemSize: 34,
                  onChanged: (value) => setState(() => _rating = value),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '코멘트 (선택, 최대 500자)',
                style: AppTextStyles.labelSmallRegular.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF655F6C),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('rating-comment-field'),
                controller: _commentController,
                enabled: !_isSubmitting,
                maxLength: 500,
                maxLines: 4,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: '이 영화의 인상적인 장면은...',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFFAF8FD),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFD8D2E0),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFD8D2E0),
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF0EBF8),
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(46),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MovieLogButton(
                      label: '확인',
                      buttonKey: const Key('confirm-rating-button'),
                      isLoading: _isSubmitting,
                      onPressed: _rating >= 1 ? _submit : null,
                      height: 46,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
