import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 프로필 수정 버튼. onPressed가 null이면(내 정보를 아직 못 불러왔을 때) 비활성화됩니다.
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.violet,
          elevation: 0,
          side: const BorderSide(color: AppColors.violet),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('프로필 수정'),
      ),
    );
  }
}
