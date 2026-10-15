import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.x2_5,
        bottom: AppSpacing.x4,
      ),
      child: Align(
        child: SizedBox(
          key: const Key('edit-profile-button'),
          width: 128,
          height: 42,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x1,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: AppColors.primary),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.medium,
              ),
              textStyle: AppTextStyles.profileButton,
            ),
            child: const Text('프로필 수정'),
          ),
        ),
      ),
    );
  }
}
