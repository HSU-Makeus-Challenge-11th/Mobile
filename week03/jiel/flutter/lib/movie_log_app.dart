import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'screens/start_screen.dart'; // StartScreen 클래스 불러오기
import 'theme/app_theme.dart';
import 'package:movielog/router/app_router.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      scrollBehavior: const _DragScrollBehavior(),
    );
  }
}

// 데스크톱·웹에서도 마우스로 끌어서 스크롤할 수 있게 한다.
class _DragScrollBehavior extends MaterialScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}