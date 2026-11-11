import 'package:flutter/material.dart';

/// Neutral surface + text colours for one brightness.
///
/// Registered as a [ThemeExtension] so every widget reads colours through
/// `context.emo` and light / dark mode stay in sync automatically.
@immutable
class EmoPalette extends ThemeExtension<EmoPalette> {
  final Brightness brightness;
  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Foreground used on top of a solid accent fill (buttons, active pills).
  final Color onAccent;

  /// Brand accent used where no emotion colour applies.
  final Color brand;

  /// Used for "low confidence" notices.
  final Color caution;

  /// Used for failures.
  final Color danger;

  const EmoPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.onAccent,
    required this.brand,
    required this.caution,
    required this.danger,
  });

  bool get isDark => brightness == Brightness.dark;

  static const EmoPalette dark = EmoPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0C0E14),
    surface: Color(0xFF14171F),
    surfaceRaised: Color(0xFF1B1F2A),
    surfaceSunken: Color(0xFF0F1218),
    border: Color(0x14FFFFFF),
    borderStrong: Color(0x26FFFFFF),
    textPrimary: Color(0xFFF3F4F7),
    textSecondary: Color(0xFFA4AABA),
    textTertiary: Color(0xFF6B7285),
    onAccent: Color(0xFF0C0E14),
    brand: Color(0xFF7C8CFF),
    caution: Color(0xFFF2B45A),
    danger: Color(0xFFF27A8A),
  );

  static const EmoPalette light = EmoPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF6F5F2),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF1F0EC),
    surfaceSunken: Color(0xFFECEBE6),
    border: Color(0x14000000),
    borderStrong: Color(0x26000000),
    textPrimary: Color(0xFF14161C),
    textSecondary: Color(0xFF5B6070),
    textTertiary: Color(0xFF8D92A0),
    onAccent: Color(0xFFFFFFFF),
    brand: Color(0xFF4F5BD5),
    caution: Color(0xFFB7791F),
    danger: Color(0xFFC9435A),
  );

  @override
  EmoPalette copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? onAccent,
    Color? brand,
    Color? caution,
    Color? danger,
  }) {
    return EmoPalette(
      brightness: brightness ?? this.brightness,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      onAccent: onAccent ?? this.onAccent,
      brand: brand ?? this.brand,
      caution: caution ?? this.caution,
      danger: danger ?? this.danger,
    );
  }

  @override
  EmoPalette lerp(ThemeExtension<EmoPalette>? other, double t) {
    if (other is! EmoPalette) return this;
    return EmoPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension EmoThemeContext on BuildContext {
  EmoPalette get emo => Theme.of(this).extension<EmoPalette>() ?? EmoPalette.dark;
  TextTheme get text => Theme.of(this).textTheme;
}
