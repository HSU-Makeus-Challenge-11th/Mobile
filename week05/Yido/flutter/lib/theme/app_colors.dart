import 'package:flutter/material.dart';

/// MovieLog 디자인 시스템(Figma)의 색상값을 한곳에서 관리한다.
abstract final class AppColors {
  // Primary
  static const primary100 = Color(0xFFF3EFFF);
  static const primary200 = Color(0xFFE9DDFF);
  static const primary300 = Color(0xFFD0BCFF);
  static const primary400 = Color(0xFFB69DF8);
  static const primary500 = Color(0xFF6750A4);
  static const primary600 = Color(0xFF4F378A);
  static const primary700 = Color(0xFF381E72);
  static const primary800 = Color(0xFF22005C);
  static const primary900 = Color(0xFF10002B);

  // Secondary
  static const secondary100 = Color(0xFFF5F3F7);
  static const secondary200 = Color(0xFFE8DEF9);
  static const secondary300 = Color(0xFFCCC2DC);
  static const secondary400 = Color(0xFFB0A7C0);
  static const secondary500 = Color(0xFF625B71);
  static const secondary600 = Color(0xFF4A4358);
  static const secondary700 = Color(0xFF332D41);
  static const secondary800 = Color(0xFF1E192B);
  static const secondary900 = Color(0xFF0F0B1A);

  // Tertiary
  static const tertiary100 = Color(0xFFFFDF93);
  static const tertiary200 = Color(0xFFE7C365);
  static const tertiary300 = Color(0xFFC9A74D);
  static const tertiary500 = Color(0xFF765B00);
  static const tertiary700 = Color(0xFF594400);
  static const tertiary900 = Color(0xFF241A00);

  // Surface
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF5F3F0);
  static const surface = Color(0xFFFAF9F5);
  static const surfaceContainer = Color(0xFFEFEEEA);
  static const surfaceHigh = Color(0xFFE9E8E4);
  static const surfaceHighest = Color(0xFFE3E2DF);

  // Text
  static const textStrong = Color(0xFF1B1C1A); // Neutral 900
  static const textPrimary = Color(0xFF1D1B20);
  static const textSecondary = Color(0xFF494551);

  static const outline = Color(0xFFCBC4D2);
  static const white = Color(0xFFFFFFFF);
}
