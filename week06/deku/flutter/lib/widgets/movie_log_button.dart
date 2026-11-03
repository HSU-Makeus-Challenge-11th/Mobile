import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class MovieLogButton extends StatelessWidget {
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 44,
    this.buttonKey,
    this.disabledBackgroundColor = AppColors.gray,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Key? buttonKey;
  final Color disabledBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      child: ElevatedButton(
        key: buttonKey,
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
          textStyle: AppTextStyles.labelLargeBold,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(label),
      ),
    );

    if (width == null) return button;
    return SizedBox(width: width, child: button);
  }
}
