import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MovieNavigationBar extends StatelessWidget {
  const MovieNavigationBar({super.key, required this.location});
  final String location;
  int get _index => location == '/movies'
      ? 1
      : location == '/my'
      ? 2
      : 0;
  @override
  Widget build(BuildContext context) => NavigationBar(
    height: 80,
    backgroundColor: const Color(0xFFFAF9F5),
    indicatorColor: Colors.transparent,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    selectedIndex: _index,
    onDestinationSelected: (value) =>
        context.go(['/home', '/movies', '/my'][value]),
    destinations: [
      _destination(Icons.home_outlined, Icons.home, '홈', 56, 40.8),
      _destination(Icons.movie_outlined, Icons.movie, '영화', 63, 44),
      _destination(Icons.person_outline, Icons.person, '마이', 63, 44),
    ],
  );
  NavigationDestination _destination(
    IconData icon,
    IconData selectedIcon,
    String label,
    double width,
    double height,
  ) => NavigationDestination(
    label: label,
    icon: _tab(icon, label, width, height, false),
    selectedIcon: _tab(selectedIcon, label, width, height, true),
  );
  Widget _tab(
    IconData icon,
    String label,
    double width,
    double height,
    bool selected,
  ) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8DEF9) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: label == '홈' ? 16 : 20,
            color: selected ? const Color(0xFF686177) : const Color(0xFF494551),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: selected
                  ? const Color(0xFF686177)
                  : const Color(0xFF494551),
            ),
          ),
        ],
      ),
    ),
  );
}
