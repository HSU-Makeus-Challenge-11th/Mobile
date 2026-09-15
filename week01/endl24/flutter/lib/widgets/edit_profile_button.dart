import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 프로필 수정 버튼. 1주차에는 모양만 구현하고 실제 동작은 넣지 않는다.
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
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
