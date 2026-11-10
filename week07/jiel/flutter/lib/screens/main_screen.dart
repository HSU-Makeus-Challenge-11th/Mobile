import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  static const _paths = ['/home', '/movies', '/my'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: -10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 80,
          backgroundColor: AppColors.surfaceBase,
          elevation: 0,
          // 기본 인디케이터는 아이콘만 감싸므로 끄고, 아이콘+글씨를 함께 감싼
          // _NavPill을 아이콘 자리에 넣는다. 글씨는 _NavPill 안에 있으니 기본 라벨은 숨긴다.
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => context.go(_paths[index]),
          destinations: const [
            NavigationDestination(
              icon: _NavPill(icon: Icons.home_outlined, label: '홈'),
              selectedIcon: _NavPill(
                icon: Icons.home,
                label: '홈',
                selected: true,
              ),
              label: '홈',
            ),
            NavigationDestination(
              icon: _NavPill(icon: Icons.movie_outlined, label: '영화'),
              selectedIcon: _NavPill(
                icon: Icons.movie,
                label: '영화',
                selected: true,
              ),
              label: '영화',
            ),
            NavigationDestination(
              icon: _NavPill(icon: Icons.person_outline, label: '마이'),
              selectedIcon: _NavPill(
                icon: Icons.person,
                label: '마이',
                selected: true,
              ),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}

// 아이콘과 글씨를 함께 감싸는 탭 모양
class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.secondary200 : Colors.transparent,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
