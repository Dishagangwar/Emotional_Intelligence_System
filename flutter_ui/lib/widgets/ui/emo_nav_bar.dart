import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'pressable.dart';

@immutable
class EmoNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const EmoNavItem({required this.icon, required this.activeIcon, required this.label});
}

/// Floating, frosted bottom navigation bar.
class EmoNavBar extends StatelessWidget {
  final List<EmoNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final Color accent;

  const EmoNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(EmoSpace.gutter, 0, EmoSpace.gutter, bottom > 0 ? bottom : EmoSpace.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 68,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: p.surface.withValues(alpha: p.isDark ? 0.78 : 0.86),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: p.borderStrong.withValues(alpha: p.isDark ? 0.5 : 0.4)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          selected: i == index,
                          accent: accent,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final EmoNavItem item;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.selected, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final fg = selected ? p.textPrimary : p.textTertiary;

    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: item.label,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: EmoMotion.medium,
        curve: EmoMotion.standard,
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: p.isDark ? 0.14 : 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: EmoMotion.fast,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey(selected),
                  size: 22,
                  color: selected ? accent : fg,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: context.text.labelSmall?.copyWith(
                  color: fg,
                  letterSpacing: 0.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
