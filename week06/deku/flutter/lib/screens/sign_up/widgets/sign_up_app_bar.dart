import 'package:flutter/material.dart';
import '../../../theme/app_text_styles.dart';

class SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SignUpAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text('회원가입', style: AppTextStyles.signUpAppBarTitle),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
