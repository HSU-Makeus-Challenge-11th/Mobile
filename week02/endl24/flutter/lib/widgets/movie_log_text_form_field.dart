import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class MovieLogTextFormField extends StatefulWidget {
  const MovieLogTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<MovieLogTextFormField> createState() => _MovieLogTextFormFieldState();
}

class _MovieLogTextFormFieldState extends State<MovieLogTextFormField> {
  late bool _obscured = widget.obscureText;
  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final hasError = text.isNotEmpty && widget.validator(text) != null;
    final isValid = text.isNotEmpty && widget.validator(text) == null;
    final stateIcon = hasError
        ? const Icon(Icons.error_outline, color: AppColors.red)
        : isValid
        ? const Icon(Icons.check_circle, color: AppColors.violet)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscured,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodySmall,
            filled: true,
            fillColor: hasError ? AppColors.redLight : AppColors.grayLight,
            suffixIcon: widget.obscureText
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?stateIcon,
                      IconButton(
                        icon: Icon(
                          _obscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscured = !_obscured),
                        color: AppColors.gray,
                      ),
                    ],
                  )
                : stateIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorStyle: const TextStyle(fontSize: 12, color: AppColors.red),
            enabledBorder: _border(AppColors.grayLine),
            focusedBorder: _border(AppColors.violet, width: 1.5),
            errorBorder: _border(AppColors.red),
            focusedErrorBorder: _border(AppColors.red, width: 1.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
