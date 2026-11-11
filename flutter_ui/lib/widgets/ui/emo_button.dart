import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'pressable.dart';

enum EmoButtonVariant { primary, secondary, ghost }

/// Primary call-to-action, secondary and ghost buttons.
class EmoButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final EmoButtonVariant variant;
  final Color? color;
  final bool expand;
  final bool compact;

  const EmoButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = EmoButtonVariant.primary,
    this.color,
    this.expand = false,
    this.compact = false,
  });

  const EmoButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.expand = false,
    this.compact = false,
  }) : variant = EmoButtonVariant.secondary;

  const EmoButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.expand = false,
    this.compact = true,
  }) : variant = EmoButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final accent = color ?? p.brand;

    final Color bg;
    final Color fg;
    final Color? borderColor;
    switch (variant) {
      case EmoButtonVariant.primary:
        bg = accent;
        fg = p.onAccent;
        borderColor = null;
      case EmoButtonVariant.secondary:
        bg = p.surfaceRaised;
        fg = p.textPrimary;
        borderColor = p.border;
      case EmoButtonVariant.ghost:
        bg = Colors.transparent;
        fg = accent;
        borderColor = null;
    }

    final height = compact ? 40.0 : 54.0;
    final style = (compact ? context.text.labelMedium : context.text.labelLarge)?.copyWith(color: fg);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: compact ? 18 : 20, color: fg),
          const SizedBox(width: EmoSpace.xs),
        ],
        Flexible(
          child: Text(label, style: style, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );

    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: EmoMotion.medium,
        curve: EmoMotion.standard,
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: variant == EmoButtonVariant.ghost ? 10 : (compact ? 16 : 24)),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(compact ? EmoRadius.md : 16),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: variant == EmoButtonVariant.primary && onPressed != null
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: p.isDark ? 0.28 : 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}
