import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/screens/about_screen.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// W10 마이페이지 앱바의 ⓘ: 20x20 원(2px)과 가운데 i
class AboutInfoButton extends StatelessWidget {
  const AboutInfoButton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '앱 정보',
    child: GestureDetector(
      key: const Key('aboutInfoButton'),
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AboutScreen.routePath),
      child: Padding(
        // 그려지는 원은 20x20이고 누르는 영역만 넓힌다
        padding: const EdgeInsets.all(12),
        child: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary500, width: 2),
          ),
          child: Text(
            'i',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.primary500,
            ),
          ),
        ),
      ),
    ),
  );
}
