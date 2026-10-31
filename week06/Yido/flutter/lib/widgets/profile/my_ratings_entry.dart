import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class MyRatingsEntry extends StatelessWidget {
  const MyRatingsEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        minTileHeight: 65,
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD6C9E8), width: 2),
        ),
        title: Text(
          '내가 등록한 평점',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary500),
        onTap: () => context.push('/my/ratings'),
      ),
    );
  }
}
