import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

/// 여러 화면이 함께 쓰는 공용 버튼. 상태는 표시만 하고 스스로 바꾸지 않는다.
class MovieLogButton extends StatelessWidget {
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.disabledColor = AppColors.gray,
    this.labelStyle = _defaultLabelStyle,
    this.height = 44,
    this.backgroundColor = AppColors.primary500,
    this.foregroundColor = AppColors.white,
    this.borderRadius = 12,
    this.horizontalPadding = 25,
  });

  static const _defaultLabelStyle = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w700,
  );

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// null: 내용 기반 크기, double.infinity: 부모가 허용하는 최대 너비, 그 외: 고정 값
  final double? width;
  final Color disabledColor;
  final TextStyle labelStyle;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final double horizontalPadding;

  bool get _disabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? Stack(
                alignment: Alignment.center,
                children: [
                  // 글자는 그리지 않고 자리만 남겨 통신 중에도 버튼 너비를 유지한다
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Text(label, style: labelStyle),
                  ),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                ],
              )
            : Text(label, style: labelStyle),
      ),
    );
  }
}
