import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.surfaceBase,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary500,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary200,
      onPrimaryContainer: AppColors.primary900,
      secondary: AppColors.secondary500,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary200,
      onSecondaryContainer: AppColors.secondary900,
      tertiary: AppColors.tertiary500,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiary100,
      onTertiaryContainer: Color(0xFF503D00), // text color on Tertiary 100~300 swatches
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: AppColors.surfaceBase,
      onSurface: AppColors.neutral900,
      onSurfaceVariant: Color(0xFF494551), // caption/subtitle text color
      outline: Color(0xFFCBC4D2), // card & divider border color
      outlineVariant: AppColors.neutral600,
      surfaceContainerLowest: AppColors.surfaceLowest,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
      inverseSurface: AppColors.neutral900,
      onInverseSurface: AppColors.surfaceLowest,
      inversePrimary: AppColors.primary200,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    // Roles not covered by the "2. Typography Guide" spec fall back to Flutter's default Typography.
    textTheme: const TextTheme(
      displayLarge: AppTextStyle.displayLarge,
      headlineLarge: AppTextStyle.headlineLarge,
      headlineMedium: AppTextStyle.headlineMedium,
      headlineSmall: AppTextStyle.headlineSmall,
      titleLarge: AppTextStyle.titleLarge,
      titleMedium: AppTextStyle.titleMedium,
      titleSmall: AppTextStyle.titleSmall,
      bodyLarge: AppTextStyle.bodyLarge,
      bodyMedium: AppTextStyle.bodyMedium,
      labelLarge: AppTextStyle.labelLarge,
      labelMedium: AppTextStyle.labelMedium,
      labelSmall: AppTextStyle.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceBase,
      foregroundColor: AppColors.neutral900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyle.appBarTitle.copyWith(
        color: AppColors.neutral900,
      ),
    ),
  );
}
