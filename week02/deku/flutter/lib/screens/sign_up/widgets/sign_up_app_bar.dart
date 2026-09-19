import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SignUpAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      leadingWidth: 48,
      leading: IconButton(
        onPressed: () {},
        tooltip: '뒤로 가기',
        icon: SvgPicture.asset(
          AppAssets.arrowBackIcon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.profileOnSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: const Text('회원가입', style: AppTextStyles.signUpAppBarTitle),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
