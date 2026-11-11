import 'package:flutter/animation.dart';

/// Spacing scale (4pt base). Use these instead of magic numbers.
abstract final class EmoSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal page gutter.
  static const double gutter = 16;

  /// Content never grows wider than this on tablets / desktop / web.
  static const double maxContentWidth = 640;

  /// Bottom padding so content clears the floating navigation bar.
  static const double navClearance = 32;
}

/// Corner radii.
abstract final class EmoRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Motion durations and curves.
abstract final class EmoMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration ambient = Duration(milliseconds: 900);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
}
