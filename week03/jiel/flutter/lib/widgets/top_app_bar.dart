import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key, required this.title, this.actions = const []});

  final String title;

  /// 오른쪽 끝에 놓을 버튼들 (예: 필터 아이콘)
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    // 배경색은 상태바 뒤까지 칠하고, 내용은 SafeArea 아래 64px 안에 둔다.
    return ColoredBox(
      color: AppColors.surfaceBase,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          padding: EdgeInsets.only(left: 16, right: actions.isEmpty ? 16 : 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: AppColors.primary500),
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
