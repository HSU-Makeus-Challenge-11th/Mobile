import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movielog_button.dart';

/// 평점 삭제 확인 프레임 값의 어두운 막. showDialog의 barrierColor로 넘긴다
const deleteRatingBarrierColor = Color(0x5225232A);

/// 삭제까지 마치면 true, 취소하면 요청 없이 false를 돌려준다
class DeleteRatingDialog extends StatefulWidget {
  const DeleteRatingDialog({super.key, required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<DeleteRatingDialog> {
  static const _buttonStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    height: 19 / 14,
    fontWeight: FontWeight.w700,
  );

  bool _isDeleting = false;

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is DioException
                ? writeErrorMessage(error)
                : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 31),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 36, 18, 37),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '평점을 삭제할까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 21,
                  height: 29 / 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 19),
              const Text(
                '삭제한 평점은 복구할 수 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  height: 19 / 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 56),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      width: double.infinity,
                      horizontalPadding: 0,
                      backgroundColor: const Color(0xFFF0EAF8),
                      foregroundColor: AppColors.primary500,
                      labelStyle: _buttonStyle,
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  Expanded(
                    child: MovieLogButton(
                      key: const Key('confirmDeleteButton'),
                      label: '삭제',
                      width: double.infinity,
                      horizontalPadding: 0,
                      labelStyle: _buttonStyle,
                      isLoading: _isDeleting,
                      onPressed: _onConfirm,
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
