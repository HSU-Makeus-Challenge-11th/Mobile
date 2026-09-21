import 'package:flutter/material.dart';
import 'package:movielog/profile_screen.dart';
import 'package:movielog/theme/app_theme.dart';

/// 앱 전체 설정(테마, 제목, 첫 화면)을 담당한다.
class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      // 첫 화면을 바꾸려면 위 import와 함께 바꾼다. (StartScreen / ProfileScreen)
      home: const ProfileScreen(),
    );
  }
}
