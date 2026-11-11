import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'pressable.dart';

/// Selectable filter pill. Selected = solid brand blue. An optional [dot]
/// colour identifies a category (e.g. an emotional state).
class EmoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? dot;
  final IconData? icon;
  final String? trailing;

  const EmoChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.dot,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final fg = selected ? p.onAccent : p.textSecondary;

    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: EmoMotion.fast,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? p.brand : p.surface,
          borderRadius: BorderRadius.circular(EmoRadius.pill),
          border: Border.all(color: selected ? p.brand : p.border),
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: p.onAccent, width: 1.5)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label, style: context.text.labelMedium?.copyWith(color: fg)),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                Text(
                  trailing!,
                  style: context.text.labelMedium
                      ?.copyWith(
                        color: selected
                            ? p.onAccent.withValues(alpha: 0.75)
                            : p.textTertiary,
                      )
                      .tabular,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
