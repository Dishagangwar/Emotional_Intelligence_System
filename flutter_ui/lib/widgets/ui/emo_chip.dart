import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'pressable.dart';

/// Selectable pill used for filters and option pickers.
class EmoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;
  final String? emoji;
  final String? trailing;

  const EmoChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
    this.icon,
    this.emoji,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final accent = color ?? p.brand;
    final fg = selected ? p.textPrimary : p.textSecondary;

    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: EmoMotion.medium,
        curve: EmoMotion.standard,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: p.isDark ? 0.16 : 0.12) : p.surfaceRaised,
          borderRadius: BorderRadius.circular(EmoRadius.pill),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.6) : p.border,
          ),
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? accent : p.textTertiary),
                const SizedBox(width: 6),
              ],
              Text(label, style: context.text.labelMedium?.copyWith(color: fg)),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                Text(
                  trailing!,
                  style: context.text.labelSmall?.copyWith(
                    color: selected ? accent : p.textTertiary,
                    letterSpacing: 0,
                  ).tabular,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
