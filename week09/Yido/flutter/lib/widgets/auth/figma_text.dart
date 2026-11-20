import 'package:flutter/material.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// W8 프레임의 글자는 모두 line-height 125%라 상자 높이를 글자 크기 x 1.25로 고정한다
TextStyle w8Text(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: AppTextStyles.fontFamily,
  fontSize: size,
  height: 1.25,
  fontWeight: weight,
  color: color,
);

StrutStyle w8Strut(double size) => StrutStyle(
  fontFamily: AppTextStyles.fontFamily,
  fontSize: size,
  height: 1.25,
  forceStrutHeight: true,
);
