import 'package:flutter/material.dart';
import 'emo_palette.dart';

/// Type scale for Emostate.
///
/// Uses the platform's native UI font (SF Pro on Apple platforms, Roboto on
/// Android) so the app ships with zero font dependencies and works offline.
/// To use a bundled brand font instead, declare it in pubspec.yaml and set
/// [fontFamily] — every style below picks it up.
abstract final class EmoTypography {
  static const String? fontFamily = null;

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(EmoPalette p) {
    TextStyle base(double size, FontWeight weight, Color color,
            {double height = 1.3, double spacing = 0}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: spacing,
        );

    return TextTheme(
      // Hero numbers & state names
      displayLarge: base(44, FontWeight.w700, p.textPrimary, height: 1.05, spacing: -1.4),
      displayMedium: base(36, FontWeight.w700, p.textPrimary, height: 1.08, spacing: -1.0),
      displaySmall: base(30, FontWeight.w700, p.textPrimary, height: 1.1, spacing: -0.8),
      // Screen titles
      headlineMedium: base(26, FontWeight.w700, p.textPrimary, height: 1.15, spacing: -0.6),
      headlineSmall: base(22, FontWeight.w700, p.textPrimary, height: 1.2, spacing: -0.4),
      // Card titles
      titleLarge: base(19, FontWeight.w600, p.textPrimary, height: 1.25, spacing: -0.2),
      titleMedium: base(16, FontWeight.w600, p.textPrimary, height: 1.3, spacing: -0.1),
      titleSmall: base(14, FontWeight.w600, p.textPrimary, height: 1.3),
      // Reading text
      bodyLarge: base(16, FontWeight.w400, p.textPrimary, height: 1.55),
      bodyMedium: base(14.5, FontWeight.w400, p.textSecondary, height: 1.5),
      bodySmall: base(13, FontWeight.w400, p.textSecondary, height: 1.45),
      // UI labels
      labelLarge: base(15, FontWeight.w600, p.textPrimary, spacing: -0.1),
      labelMedium: base(13, FontWeight.w600, p.textSecondary),
      // Eyebrow / overline
      labelSmall: base(11.5, FontWeight.w600, p.textTertiary, spacing: 0.8),
    );
  }
}

extension EmoTextStyleX on TextStyle {
  TextStyle get tabular => copyWith(fontFeatures: EmoTypography.tabular);
}
