import 'package:flutter/material.dart';

import '../screens/rating/rating_screen.dart';
import '../theme/app_theme.dart';

void main() {
  runApp(const RatingPreviewApp());
}

class RatingPreviewApp extends StatelessWidget {
  const RatingPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RatingScreen(),
    );
  }
}
