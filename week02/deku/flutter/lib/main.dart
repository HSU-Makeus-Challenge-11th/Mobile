
import 'package:flutter/material.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/start/start_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      home: const SignUpScreen(),
      routes: {
        StartScreen.routeName: (context) => const StartScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen()
      },
    );
  }
}
