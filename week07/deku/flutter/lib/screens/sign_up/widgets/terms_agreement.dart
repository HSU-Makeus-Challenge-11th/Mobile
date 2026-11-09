import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

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
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            key: const Key('terms-checkbox'),
            value: value,
            onChanged: (nextValue) => onChanged(nextValue ?? false),
            activeColor: AppColors.primary,
            checkColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Expanded(
            child: Text('필수 약관에 동의합니다', style: AppTextStyles.signUpFieldLabel),
          ),
        ],
      ),
    );
  }
}
