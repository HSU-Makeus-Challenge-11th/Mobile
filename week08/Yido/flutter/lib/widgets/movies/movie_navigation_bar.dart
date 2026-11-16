import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movies/tab_icons.dart';

class MovieNavigationBar extends StatelessWidget {
  const MovieNavigationBar({super.key, required this.location});
  final String location;
  int get _index => location == '/movies'
      ? 1
      : location == '/my'
      ? 2
      : 0;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.white,
    child: Padding(
      // 탭 중심을 73 · 195 · 313에 맞춘다
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: NavigationBar(
        height: 64,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: _index,
        onDestinationSelected: (value) =>
            context.go(['/home', '/movies', '/my'][value]),
        destinations: [
          _destination(TabIconShape.home, '홈'),
          _destination(TabIconShape.movie, '영화'),
          _destination(TabIconShape.my, '마이'),
        ],
      ),
    ),
  );

  NavigationDestination _destination(TabIconShape icon, String label) =>
      NavigationDestination(
        label: label,
        icon: _tab(icon, label, false),
        selectedIcon: _tab(icon, label, true),
      );

  /// 선택 표시(62x38)는 아이콘 뒤에만 깔리고 라벨은 그 아래쪽에 걸친다
  Widget _tab(TabIconShape icon, String label, bool selected) {
    final color = selected ? AppColors.primary500 : AppColors.mutedText;
    return SizedBox(
      key: Key('tab_$label'),
      width: 62,
      height: 54,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (selected)
            Container(
              width: 62,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEEE1FA),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          Positioned(
            top: selected ? 7 : 14,
            child: TabIcon(shape: icon, color: color),
          ),
          Positioned(
            top: 36,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
