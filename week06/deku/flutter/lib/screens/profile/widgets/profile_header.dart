import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox.square(
          key: const Key('profile-photo'),
          dimension: 128,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipOval(
                child: ColoredBox(
                  color: AppColors.primary200,
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.personIcon,
                      width: 48,
                      height: 48,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: '기본 프로필 영화 아이콘',
                    ),
                  ),
                ),
              ),
              ClipOval(
                child: Image.asset(
                  AppAssets.profile,
                  fit: BoxFit.cover,
                  semanticLabel: '무비러버 프로필 사진',
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary300, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        const Text('무비러버', style: AppTextStyles.profileName),
        const SizedBox(height: AppSpacing.x1_5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 321),
          child: const Text(
            '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
            textAlign: TextAlign.center,
            style: AppTextStyles.profileDescription,
          ),
        ),
      ],
    );
  }
}
