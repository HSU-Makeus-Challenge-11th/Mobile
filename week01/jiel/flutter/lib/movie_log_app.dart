import 'package:flutter/material.dart';
import 'start_screen.dart'; // StartScreen 클래스 불러오기

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const StartScreen(), // 첫 실행 화면 지정
    );
  }
}