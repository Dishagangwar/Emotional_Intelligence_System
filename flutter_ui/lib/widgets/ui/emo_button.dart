import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'pressable.dart';

enum EmoButtonVariant { primary, secondary, ghost }

/// Buttons. Primary actions are always the brand blue so the main action on
/// any screen is instantly recognisable.
class EmoButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final EmoButtonVariant variant;
  final bool expand;
  final bool compact;

  const EmoButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = EmoButtonVariant.primary,
    this.expand = false,
    this.compact = false,
  });

  const EmoButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expand = false,
    this.compact = false,
  }) : variant = EmoButtonVariant.secondary;

  const EmoButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expand = false,
    this.compact = true,
  }) : variant = EmoButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    final Color bg;
    final Color fg;
    final Color? borderColor;
    switch (variant) {
      case EmoButtonVariant.primary:
        bg = p.brand;
        fg = p.onAccent;
        borderColor = null;
      case EmoButtonVariant.secondary:
        bg = p.surface;
        fg = p.textPrimary;
        borderColor = p.borderStrong;
      case EmoButtonVariant.ghost:
        bg = Colors.transparent;
        fg = p.brand;
        borderColor = null;
    }

    final height = compact ? 38.0 : 48.0;
    final style = (compact ? context.text.labelMedium : context.text.labelLarge)
        ?.copyWith(color: fg);

    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: EmoMotion.fast,
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: variant == EmoButtonVariant.ghost
              ? 8
              : (compact ? 14 : 20),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(EmoRadius.md),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: compact ? 17 : 19, color: fg),
                const SizedBox(width: EmoSpace.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: style,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
