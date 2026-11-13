import 'package:flutter/material.dart';

abstract final class AppColors {
  static const violet = Color(0xFF6750A4);

  static const warmWhite = Color(0xFFFAF9F5);
  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF1C1B1F);
  static const gray = Color(0xFF79747E);

  static const violetDark = Color(0xFF4F378A);
  static const grayDark = Color(0xFF4A4358);

  /// 장르 Chip 배경 등에 쓰는 연보라색 (Figma Primary 200)
  static const violetLight = Color(0xFFE9DDFF);

  /// 비활성 버튼 배경
  static const violetMuted = Color(0xFFCCC2DC);

  /// 입력창 배경과 기본 테두리
  static const grayLight = Color(0xFFF3F1EC);
  static const grayLine = Color(0xFFCAC4D0);

  /// 입력 오류 테두리·문구·아이콘과 오류 배경
  static const red = Color(0xFFB3261E);
  static const redLight = Color(0xFFF9DEDC);
}
