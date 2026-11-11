import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The base surface for grouped content.
///
/// Pass an [accent] to give the card a soft tinted wash and border, used to
/// tie a card to the current emotional state.
class EmoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final double radius;
  final bool sunken;

  const EmoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(EmoSpace.lg),
    this.accent,
    this.radius = EmoRadius.lg,
    this.sunken = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final accent = this.accent;
    final base = sunken ? p.surfaceSunken : p.surface;

    return AnimatedContainer(
      duration: EmoMotion.slow,
      curve: EmoMotion.standard,
      padding: padding,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: accent != null ? accent.withValues(alpha: p.isDark ? 0.22 : 0.28) : p.border,
        ),
        gradient: accent == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(accent.withValues(alpha: p.isDark ? 0.10 : 0.07), base),
                  base,
                ],
                stops: const [0, 0.65],
              ),
        boxShadow: p.isDark || sunken
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
  }
}
