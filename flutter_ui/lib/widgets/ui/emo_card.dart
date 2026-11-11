import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The base surface for grouped content: white, 1px hairline border and a
/// barely-there shadow. Colour is never used for the card itself — accents
/// live in the small elements inside it.
class EmoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool sunken;

  /// Optional emphasis border (e.g. a selected card).
  final Color? highlight;

  const EmoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(EmoSpace.md),
    this.radius = EmoRadius.lg,
    this.sunken = false,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return AnimatedContainer(
      duration: EmoMotion.medium,
      curve: EmoMotion.standard,
      padding: padding,
      decoration: BoxDecoration(
        color: sunken ? p.surfaceSunken : p.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: highlight ?? p.border,
          width: highlight != null ? 1.5 : 1,
        ),
        boxShadow: p.isDark || sunken
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
