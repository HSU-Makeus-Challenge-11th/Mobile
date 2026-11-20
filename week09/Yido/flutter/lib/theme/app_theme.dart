import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 앱 전체에 공통으로 적용하는 Theme 설정.
abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.surface,
    // 디자인 시스템에 있는 색은 직접 지정하고, 나머지는 Primary 기준으로 생성한다.
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary500,
      primary: AppColors.primary500,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primary200,
      onPrimaryContainer: AppColors.primary600,
      secondary: AppColors.secondary500,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondary200,
      onSecondaryContainer: AppColors.secondary700,
      tertiary: AppColors.tertiary500,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.tertiary100,
      onTertiaryContainer: AppColors.tertiary900,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.surfaceLowest,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
      outline: AppColors.outline,
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTextStyles.headlineMedium,
      titleLarge: AppTextStyles.titleLarge,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
