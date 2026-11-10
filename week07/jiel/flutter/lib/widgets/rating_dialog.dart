import 'package:flutter/material.dart';

import '../data/models/rating_request.dart';
import '../theme/app_colors.dart';
import 'movie_rating_input.dart';
import 'movielog_button.dart';

/// 평점 등록·수정 공용 Dialog. 별점 아래에 코멘트 TextField(선택, 최대 500자)를 둔다.
///
/// 저장 로직은 [onSubmit] 콜백으로 받아 Dialog **안에서** 실행한다.
/// - onSubmit이 예외 없이 끝나면 `Navigator.pop(context, true)`
/// - 사용자가 취소하면 onSubmit을 호출하지 않고 false를 반환
/// - 아직 아무 동작도 하지 않은 상태로 닫히면 null (뒤로가기 등)
///
/// 저장 중에는 `PopScope(canPop: false)`로 뒤로가기를 막는다. 바깥 탭으로 닫히는 것까지 막으려면
/// 호출부에서 `showDialog(barrierDismissible: false)`를 함께 지정해야 한다.
///
/// 수정 시에는 [initialScore]/[initialComment]에 기존 값을 넣어 Dialog가 열리자마자 이전 입력을 보여준다.
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  static const int maxCommentLength = 500;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;

  // build() 안에서 TextEditingController(text: ...)를 매번 새로 만들면 별점을 고를 때마다
  // 입력하던 코멘트가 사라지므로, State가 살아 있는 동안 한 번만 만든다.
  late final TextEditingController _commentController =
      TextEditingController(text: widget.initialComment ?? '');

  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    // Dialog를 여러 번 열고 닫아도 컨트롤러가 쌓이지 않게 해제한다.
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_isSubmitting || _score < 1) return; // 연속 탭 방지
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final trimmed = _commentController.text.trim();
    if (trimmed.length > RatingDialog.maxCommentLength) {
      setState(() {
        _isSubmitting = false;
        _errorText = '코멘트는 500자 이하로 입력해 주세요.';
      });
      return;
    }

    try {
      // 빈 문자열은 null로 바꿔 요청한다.
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      // 실패 시 반드시 로딩을 풀어야 다시 시도할 수 있다. 입력값은 그대로 남는다.
      setState(() {
        _isSubmitting = false;
        _errorText = error is StateError
            ? error.message
            : '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;

    return PopScope(
      // 저장 중에는 뒤로가기(스와이프 백 포함)로 Dialog가 닫히지 않게 한다.
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.surfaceBase,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '평점을 남겨주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  height: 27 / 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF25232A),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: MovieRatingInput(
                  rating: _score.toDouble(),
                  enabled: !_isSubmitting,
                  onChanged: (value) => setState(
                    () => _score = validateServerScore(value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '코멘트 (선택, 최대 ${RatingDialog.maxCommentLength}자)',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: RatingDialog.maxCommentLength,
                enabled: !_isSubmitting,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: '이 영화의 감상평을 남겨보세요.',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral800,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBC4D2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBC4D2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary500),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errorText!,
                  style: textTheme.labelMedium?.copyWith(color: errorColor),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      height: 48,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    // 별점을 선택해야만 활성화된다. 코멘트만 입력해서는 확인을 누를 수 없다.
                    child: MovieLogButton(
                      label: '확인',
                      height: 48,
                      isLoading: _isSubmitting,
                      onPressed:
                          _score > 0 && !_isSubmitting ? _onConfirm : null,
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
