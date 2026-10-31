import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 테두리만 있는 보조 버튼이라 TextButton에 테두리를 더해 만든다.
/// 1주차에는 모양만 구현하고 화면 이동은 하지 않는다.
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 40,
      child: TextButton(
        onPressed: () {
          debugPrint('프로필 수정 버튼을 눌렀습니다.');
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary500,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: AppColors.primary500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('프로필 수정'),
      ),
    );
  }
}
