import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.child});

  final Widget child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // 어느 탭으로 들어오든 내 정보를 한 번 불러와 AuthViewModel.member에 보관합니다.
    // loadMember()는 바로 notifyListeners()를 부르므로 첫 build가 끝난 뒤 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().loadMember();
    });
  }

  static const _tabs = <_TabItem>[
    _TabItem(path: '/home', icon: Icons.home_outlined, selectedIcon: Icons.home, label: '홈'),
    _TabItem(path: '/movies', icon: Icons.movie_outlined, selectedIcon: Icons.movie, label: '영화'),
    _TabItem(path: '/my', icon: Icons.person_outline, selectedIcon: Icons.person, label: '마이'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((tab) => location.startsWith(tab.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.violetLight,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon, color: AppColors.violet),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}