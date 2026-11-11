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

  /// Primary theme: clean, clinical light.
  static const EmoPalette light = EmoPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF1F4F8),
    surfaceSunken: Color(0xFFEEF2F6),
    border: Color(0xFFE3E8EF),
    borderStrong: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    onAccent: Color(0xFFFFFFFF),
    brand: Color(0xFF2563EB),
    caution: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  /// Optional dark counterpart (slate), same clinical language.
  static const EmoPalette dark = EmoPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0B1220),
    surface: Color(0xFF111A2B),
    surfaceRaised: Color(0xFF17223A),
    surfaceSunken: Color(0xFF0E1626),
    border: Color(0xFF1F2B44),
    borderStrong: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    onAccent: Color(0xFFFFFFFF),
    brand: Color(0xFF3B82F6),
    caution: Color(0xFFF59E0B),
    danger: Color(0xFFF87171),
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
  EmoPalette get emo =>
      Theme.of(this).extension<EmoPalette>() ?? EmoPalette.dark;
  TextTheme get text => Theme.of(this).textTheme;
}
