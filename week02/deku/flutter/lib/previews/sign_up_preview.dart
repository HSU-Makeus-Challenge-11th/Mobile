import 'package:flutter/material.dart';

import '../screens/sign_up/sign_up_screen.dart';
import '../theme/app_theme.dart';

void main() {
  runApp(const SignUpPreviewApp());
}

class SignUpPreviewApp extends StatelessWidget {
  const SignUpPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SignUpScreen(),
    );
  }
}
