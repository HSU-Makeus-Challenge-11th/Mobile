import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens from the MovieLog W1 typography guide.
abstract final class AppTextStyles {
  static const fontFamily = 'Manrope';

  static const titleLarge = titleLargeBold;
  static const titleMedium = titleMediumSemiBold;
  static const bodyLarge = bodyLargeRegular;
  static const bodyMedium = bodyMediumRegular;
  static const labelLarge = labelLargeSemiBold;
  static const labelSmall = labelSmallRegular;

  static const titleLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const titleLargeSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const titleLargeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const titleLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const titleMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const titleMediumSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const titleMediumMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const titleMediumRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const bodyLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const bodyLargeSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const bodyLargeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const bodyLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const bodyMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const bodyMediumSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const bodyMediumMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const bodyMediumRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const labelLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const labelLargeSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const labelLargeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const labelLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const labelSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const labelSmallSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const labelSmallMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const labelSmallRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  // W1-01 profile styles measured from the Final Sync Figma frame.
  // Manrope has no Korean glyphs, so Korean text uses the platform fallback.
  static const profileAppBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const profileName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurface,
  );

  static const profileDescription = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurfaceVariant,
  );

  static const profileButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const profileStatLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurfaceVariant,
  );

  static const profileStatValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.primary600,
  );

  static const profileSectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurface,
  );

  static const profileChipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary600,
  );

  // W2 sign-up form styles measured from the Final Sync frames.
  static const signUpAppBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const signUpIntro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurfaceVariant,
  );

  static const signUpFieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurface,
  );

  static const signUpFieldText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.profileOnSurface,
  );

  static const signUpError = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const signUpButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
}
