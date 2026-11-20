import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/movies/movie_rating_input.dart';

/// W7-01 값의 어두운 막. showDialog의 barrierColor로 넘긴다
const ratingDialogBarrierColor = Color(0x5725232A);

/// onSubmit이 이 예외를 던지면 Dialog를 닫는다. 안내는 호출한 쪽이 Snackbar로 한다
class RatingDialogDismissed implements Exception {
  const RatingDialogDismissed();
}

/// 저장은 onSubmit이 맡는다. 예외 없이 끝나면 true, 취소하면 false를 돌려준다
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    this.showAddToFavorite = false,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;

  /// 평점 수정에서도 같은 Dialog를 쓰므로 기본은 숨긴다.
  /// 상세의 "평점 남기기"에서 아직 즐겨찾기하지 않은 영화일 때만 보인다
  final bool showAddToFavorite;

  /// 체크박스가 보이지 않으면 addToFavorites는 항상 false다
  final Future<void> Function(int score, String? comment, bool addToFavorites)
  onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  static const _buttonStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w700,
  );

  late int _score = widget.initialScore;
  // build마다 만들면 별점을 고를 때 입력하던 코멘트가 사라진다
  late final _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );
  bool _isSubmitting = false;
  bool _addToFavorites = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final trimmed = _commentController.text.trim();
    try {
      await widget.onSubmit(
        _score,
        trimmed.isEmpty ? null : trimmed,
        widget.showAddToFavorite && _addToFavorites,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on RatingDialogDismissed {
      if (!mounted) return;
      Navigator.pop(context, false);
    } catch (error) {
      if (!mounted) return;
      // 실패해도 Dialog를 유지해 입력한 별점과 코멘트를 보존한다
      setState(() {
        _isSubmitting = false;
        _errorText = switch (error) {
          DioException() => writeErrorMessage(error),
          StateError(:final message) => message,
          _ => '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 2),
    );

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(17, 33, 17, 38),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '평점을 남겨주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  height: 30 / 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              MovieRatingInput(
                rating: _score.toDouble(),
                enabled: !_isSubmitting,
                onChanged: (value) =>
                    setState(() => _score = validateServerScore(value)),
              ),
              const SizedBox(height: 27),
              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  '코멘트 (선택, 최대 500자)',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              SizedBox(
                height: 105,
                child: TextField(
                  key: const Key('ratingCommentField'),
                  controller: _commentController,
                  enabled: !_isSubmitting,
                  expands: true,
                  maxLines: null,
                  maxLength: 500,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: '이 영화의 인상적인 장면은…',
                    hintStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.mutedText,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAF8FD),
                    contentPadding: const EdgeInsets.fromLTRB(13, 20, 13, 13),
                    border: border(const Color(0xFFD8D2E0)),
                    enabledBorder: border(const Color(0xFFD8D2E0)),
                    disabledBorder: border(const Color(0xFFD8D2E0)),
                    focusedBorder: border(AppColors.primary500),
                  ),
                ),
              ),
              if (widget.showAddToFavorite) ...[
                const SizedBox(height: 15),
                _AddToFavoriteCheckbox(
                  value: _addToFavorites,
                  enabled: !_isSubmitting,
                  onChanged: (value) => setState(() => _addToFavorites = value),
                ),
              ],
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 3, top: 8),
                  child: Text(
                    _errorText!,
                    key: const Key('ratingErrorText'),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
              SizedBox(height: _errorText == null ? 34 : 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: MovieLogButton(
                        label: '취소',
                        width: double.infinity,
                        height: 46,
                        borderRadius: 23,
                        backgroundColor: const Color(0xFFF0EBF8),
                        foregroundColor: AppColors.primary500,
                        horizontalPadding: 0,
                        labelStyle: _buttonStyle,
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context, false),
                      ),
                    ),
                    Expanded(
                      child: MovieLogButton(
                        key: const Key('confirmRatingButton'),
                        label: '확인',
                        width: double.infinity,
                        height: 46,
                        borderRadius: 23,
                        horizontalPadding: 0,
                        labelStyle: _buttonStyle,
                        isLoading: _isSubmitting,
                        onPressed: _score > 0 ? _onConfirm : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 워크북 W9 Challenge 이미지: 20x20 보라 테두리 칸과 "즐겨찾기에도 추가"
class _AddToFavoriteCheckbox extends StatelessWidget {
  const _AddToFavoriteCheckbox({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: value,
    label: '즐겨찾기에도 추가',
    child: InkWell(
      key: const Key('addToFavoriteCheckbox'),
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? AppColors.primary500 : AppColors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primary500, width: 2),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 11),
            const Text(
              '즐겨찾기에도 추가',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                height: 19 / 14,
                fontWeight: FontWeight.w400,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
