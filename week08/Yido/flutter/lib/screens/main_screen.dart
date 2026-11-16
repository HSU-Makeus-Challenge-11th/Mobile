import 'package:flutter/material.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/widgets/movies/movie_navigation_bar.dart';
import 'package:provider/provider.dart';

/// 세 탭을 감싸는 화면. 탭을 바꿔도 유지되므로 내 정보를 여기서 한 번 불러온다
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // build 도중 notifyListeners가 불리지 않도록 첫 프레임 뒤에 호출한다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().loadMember();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: widget.child,
    bottomNavigationBar: MovieNavigationBar(location: widget.location),
  );
}
