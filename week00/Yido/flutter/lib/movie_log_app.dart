import 'package:flutter/material.dart';
import 'package:movielog/start_screen.dart';

/// 앱 전체 설정(테마, 제목, 첫 화면)을 담당한다.
class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const StartScreen(), // 첫 실행 화면 지정
    );
  }
}
