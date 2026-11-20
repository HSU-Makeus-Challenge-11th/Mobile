import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';

/// W9 하위 화면 상단: 높이 64, 왼쪽 뒤로가기(15x14), 가운데 제목 20/27
class W9AppBar extends StatelessWidget implements PreferredSizeWidget {
  const W9AppBar({super.key, required this.title, this.onTitleLongPress});

  final String title;

  /// 디버그 빌드에서 상태 화면을 고를 때만 쓴다
  final VoidCallback? onTitleLongPress;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 64,
    backgroundColor: AppColors.surfaceBright,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leadingWidth: 57,
    leading: IconButton(
      key: const Key('w9BackButton'),
      tooltip: '뒤로가기',
      padding: const EdgeInsets.only(left: 21),
      alignment: Alignment.centerLeft,
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const BackArrowIcon(),
    ),
    title: GestureDetector(
      onLongPress: onTitleLongPress,
      child: Text(
        title,
        style: w8Text(
          20,
          FontWeight.w700,
          AppColors.primary500,
        ).copyWith(height: 27 / 20),
      ),
    ),
  );
}
