import 'package:flutter/material.dart';

/// Spacing follows the assignment's 8 px base unit.
abstract final class AppSpacing {
  static const unit = 8.0;
  static const x0_5 = unit / 2;
  static const x1 = unit;
  static const x1_5 = unit * 1.5;
  static const x2 = unit * 2;
  static const x2_5 = unit * 2.5;
  static const x3 = unit * 3;
  static const x4 = unit * 4;
  static const x4_5 = unit * 4.5;
  static const x5 = unit * 5;
  static const x6 = unit * 6;
}

/// Component corners use the assignment's 8 px radius by default.
abstract final class AppRadius {
  static const value = 8.0;
  static const medium = BorderRadius.all(Radius.circular(value));
  static const large = BorderRadius.all(Radius.circular(12));
  static const pill = BorderRadius.all(Radius.circular(value * 2));
}
