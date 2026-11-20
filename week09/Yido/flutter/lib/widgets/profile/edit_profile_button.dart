import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';

/// 테두리만 있는 보조 버튼 (W8-06: 128x40, radius 9)
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 40,
      child: TextButton(
        key: const Key('editProfileButton'),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary500,
          disabledForegroundColor: AppColors.primary500.withValues(alpha: .4),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: AppColors.primary500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: w8Text(15, FontWeight.w700, AppColors.primary500),
        ),
        child: const Text('프로필 수정'),
      ),
    );
  }
}
