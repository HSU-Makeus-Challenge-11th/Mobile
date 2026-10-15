import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

enum FieldValidationState { none, valid, invalid }

class MovieLogTextFormField extends StatelessWidget {
  const MovieLogTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onChanged,
    required this.validationState,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.isPassword = false,
    this.onToggleObscure,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;
  final FieldValidationState validationState;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final bool isPassword;
  final VoidCallback? onToggleObscure;

  bool get _hasError => validationState == FieldValidationState.invalid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.signUpFieldLabel),
        const SizedBox(height: AppSpacing.x0_5),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          style: AppTextStyles.signUpFieldText,
          cursorColor: AppColors.primary,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.signUpFieldText.copyWith(
              color: AppColors.gray,
            ),
            filled: true,
            fillColor: _hasError
                ? AppColors.errorContainer
                : AppColors.surfaceLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x2,
              vertical: AppSpacing.x1_5,
            ),
            errorStyle: AppTextStyles.signUpError,
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            suffixIcon: _buildSuffixIcon(),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (_hasError) {
      return _StatusIcon(asset: AppAssets.errorIcon, color: AppColors.error);
    }

    if (isPassword && controller.text.isNotEmpty) {
      return IconButton(
        onPressed: onToggleObscure,
        tooltip: obscureText ? '비밀번호 표시' : '비밀번호 숨기기',
        icon: SvgPicture.asset(
          obscureText ? AppAssets.visibilityIcon : AppAssets.visibilityOffIcon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    if (validationState == FieldValidationState.valid) {
      return _StatusIcon(
        asset: AppAssets.checkCircleIcon,
        color: AppColors.primary,
      );
    }

    return null;
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.asset, required this.color});

  final String asset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: SvgPicture.asset(
        asset,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
