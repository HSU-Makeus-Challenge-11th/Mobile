import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 4),
        Text(
          '필수 약관에 동의합니다',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.black),
        ),
      ],
    );
  }
}
