import 'package:flutter/material.dart';
import 'package:movielog/profile_screen.dart';
import 'start_screen.dart'; // StartScreen 클래스 불러오기
import 'theme/app_theme.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      home: const ProfileScreen()//StartScreen(), // 첫 실행 화면 지정
    );
  }
}