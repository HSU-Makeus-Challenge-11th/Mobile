import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/widgets/profile/edit_profile_button.dart';

/// 프로필 사진, 닉네임, 소개, 프로필 수정 버튼을 세로로 가운데 정렬한다.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.bio,
    required this.imagePath,
  });

  final String name;
  final String bio;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        _ProfileAvatar(imagePath: imagePath),
        Column(
          spacing: 8,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleLarge,
            ),
            Text(
              bio,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const EditProfileButton(),
      ],
    );
  }
}

/// 2px 테두리가 있는 128 크기의 원형 프로필 사진.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imagePath});

  static const _size = 128.0;

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary300, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          semanticLabel: '프로필 사진',
          // 이미지를 불러오지 못하면 기본 아이콘을 보여준다.
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: AppColors.primary100,
            child: Center(
              child: Icon(Icons.person, size: 64, color: AppColors.primary500),
            ),
          ),
        ),
      ),
    );
  }
}
