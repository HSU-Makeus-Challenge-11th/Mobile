import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

/// 화면에서 공통으로 쓰는 글자 스타일.
/// 이름은 Material 3 기본 체계를 따르고, 값은 Figma 화면(W1-00, W1-01)에 맞춘다.
/// 줄 높이는 Figma의 line-height를 글자 크기로 나눈 비율로 적는다.
abstract final class AppTextStyles {
  static const fontFamily = 'Manrope';

  /// 28/36 - 시작 화면 제목
  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w500,
    color: AppColors.textStrong,
  );

  /// 22/28 - AppBar 제목, 닉네임
  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// 16/24 - 소개 문구, 섹션 제목, 프로필 수정 버튼
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// 14/20 - 시작 화면 설명
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  /// 14/20 - 시작하기 버튼
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// 12/16 - 통계 라벨, 장르 Chip
  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// 11/16 - 주차 라벨
  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.55,
    color: AppColors.textSecondary,
  );
}
