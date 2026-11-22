import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 여러 화면이 함께 쓰는 공용 버튼.
///
/// 버튼은 상태를 "표시"만 하고, 상태를 바꾸는 결정은 ViewModel이 한다.
/// - 기본: [onPressed]가 있고 [isLoading]이 false
/// - 통신 중: [isLoading]이 true → 회색으로 비활성화되고 가운데 인디케이터만 보인다
/// - 비활성: [onPressed]가 null
///
/// [width]
/// - null: 내용(label) 길이에 맞춘 크기 (입력창 옆 보조 버튼)
/// - double.infinity: 부모가 허용하는 최대 너비 (Form 하단 제출 버튼)
/// - 고정 값: 항상 같은 크기
class MovieLogButton extends StatelessWidget {
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 44,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  bool get _disabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral600,
          disabledForegroundColor: AppColors.neutral800,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // 통신 중에는 label과 인디케이터 중 하나만 그린다.
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.neutral800,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
      ),
    );
  }
}
