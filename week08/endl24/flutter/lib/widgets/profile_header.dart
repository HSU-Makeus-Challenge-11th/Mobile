import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 마이페이지 상단 프로필입니다. 닉네임과 이메일은 GET me로 받은 내 정보입니다.
class ProfileHeader extends StatelessWidget {
  const new({super.key, required this.nickname, required this.email});

  final String nickname;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16), // 다음 요소와의 바깥 간격
          padding: const EdgeInsets.all(2), // 테두리와 사진 사이 안쪽 여백
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.violet, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile/profile_movielog.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(nickname, style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          email,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grayDark),
        ),
      ],
    );
  }
}
