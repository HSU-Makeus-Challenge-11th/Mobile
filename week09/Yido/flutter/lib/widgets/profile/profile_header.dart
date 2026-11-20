import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/profile/edit_profile_button.dart';

/// 프로필 사진, 닉네임, 이메일, 프로필 수정 버튼을 세로로 가운데 정렬한다 (W8-06).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
    this.onEdit,
  });

  /// GET me의 닉네임과 이메일. 소개 문구는 v7 응답에 없어 W8-06에서 빠졌다
  final String name;
  final String email;
  final String imagePath;

  /// 내 정보를 불러오기 전에는 null이라 수정 버튼이 꺼진다
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ProfileAvatar(imagePath: imagePath),
        const SizedBox(height: 17.4),
        SizedBox(
          height: 25,
          child: Text(
            name,
            key: const Key('profileNickname'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            strutStyle: w8Strut(20),
            style: w8Text(20, FontWeight.w700, AppColors.ink),
          ),
        ),
        const SizedBox(height: 13.21),
        SizedBox(
          height: 16,
          child: Text(
            email,
            key: const Key('profileEmail'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            strutStyle: w8Strut(13),
            style: w8Text(13, FontWeight.w500, AppColors.mutedText),
          ),
        ),
        const SizedBox(height: 54.39),
        EditProfileButton(onPressed: onEdit),
      ],
    );
  }
}

/// 2px 테두리가 있는 126 크기의 원형 프로필 사진.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imagePath});

  static const _size = 126.0;

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary500, width: 2),
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
