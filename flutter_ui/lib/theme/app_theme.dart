import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'emo_palette.dart';
import 'emo_tokens.dart';
import 'emo_typography.dart';

export 'emo_palette.dart';
export 'emo_tokens.dart';
export 'emo_typography.dart';
export 'emotion_style.dart';

/// Builds the light and dark [ThemeData] for Emostate from the design tokens.
abstract final class AppTheme {
  static ThemeData get dark => _build(EmoPalette.dark);
  static ThemeData get light => _build(EmoPalette.light);

  static ThemeData _build(EmoPalette p) {
    final textTheme = EmoTypography.textTheme(p);
    final scheme = ColorScheme.fromSeed(
      seedColor: p.brand,
      brightness: p.brightness,
    ).copyWith(
      primary: p.brand,
      onPrimary: p.onAccent,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.borderStrong,
      outlineVariant: p.border,
      error: p.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      fontFamily: EmoTypography.fontFamily,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: p.textSecondary, size: 20),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.brand,
        selectionColor: p.brand.withValues(alpha: 0.28),
        selectionHandleColor: p.brand,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withValues(alpha: p.isDark ? 0.55 : 0.3),
        showDragHandle: true,
        dragHandleColor: p.borderStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(EmoRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark ? p.surfaceRaised : p.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: p.isDark ? p.textPrimary : p.canvas,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EmoRadius.md)),
        insetPadding: const EdgeInsets.fromLTRB(EmoSpace.gutter, 0, EmoSpace.gutter, 108),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.surfaceRaised,
          borderRadius: BorderRadius.circular(EmoRadius.sm),
          border: Border.all(color: p.border),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: p.textPrimary),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
