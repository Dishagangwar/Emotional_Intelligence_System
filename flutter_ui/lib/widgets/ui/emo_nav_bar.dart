import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'pressable.dart';

@immutable
class EmoNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const EmoNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Docked bottom tab bar: white surface, hairline top border, brand blue for
/// the active tab.
class EmoNavBar extends StatelessWidget {
  final List<EmoNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  const EmoNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == index,
                        onTap: () => onChanged(i),
                      ),
                    ),
                ],
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
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final fg = selected ? p.brand : p.textTertiary;

    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: item.label,
      pressedScale: 0.94,
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.activeIcon : item.icon, size: 23, color: fg),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: context.text.labelSmall?.copyWith(
                color: fg,
                letterSpacing: 0.1,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
