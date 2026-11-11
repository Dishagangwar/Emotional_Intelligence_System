import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'pressable.dart';

/// Five-step segmented selector for 1–5 ratings (stress, energy).
class LevelSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;
  final String lowLabel;
  final String highLabel;
  final List<String> descriptors;

  const LevelSelector({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.color,
    this.lowLabel = 'Low',
    this.highLabel = 'High',
    this.descriptors = const ['Very low', 'Low', 'Moderate', 'High', 'Very high'],
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final safe = value.clamp(1, 5);

    return Semantics(
      label: label,
      value: '$safe of 5, ${descriptors[safe - 1]}',
      increasedValue: safe < 5 ? '${safe + 1} of 5' : null,
      decreasedValue: safe > 1 ? '${safe - 1} of 5' : null,
      onIncrease: safe < 5 ? () => onChanged(safe + 1) : null,
      onDecrease: safe > 1 ? () => onChanged(safe - 1) : null,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: EmoSpace.xs),
                Expanded(
                  child: Text(label, style: context.text.titleSmall, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: EmoSpace.xs),
                AnimatedSwitcher(
                  duration: EmoMotion.fast,
                  child: Text(
                    descriptors[safe - 1],
                    key: ValueKey(safe),
                    style: context.text.labelMedium?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: EmoSpace.sm),
            Row(
              children: List.generate(5, (i) {
                final level = i + 1;
                final filled = level <= safe;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 4 ? 0 : 6),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(level);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: EmoMotion.medium,
                          curve: EmoMotion.standard,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: filled
                                ? color.withValues(alpha: 0.22 + 0.15 * (level / 5) * (p.isDark ? 1 : 0.8))
                                : p.surfaceRaised,
                            borderRadius: BorderRadius.circular(EmoRadius.sm),
                            border: Border.all(
                              color: level == safe ? color.withValues(alpha: 0.9) : Colors.transparent,
                              width: 1.4,
                            ),
                          ),
                          child: Text(
                            '$level',
                            style: context.text.labelMedium?.copyWith(
                              color: filled ? p.textPrimary : p.textTertiary,
                            ).tabular,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(lowLabel,
                      style: context.text.labelSmall?.copyWith(letterSpacing: 0), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: EmoSpace.xs),
                Expanded(
                  child: Text(highLabel,
                      textAlign: TextAlign.right,
                      style: context.text.labelSmall?.copyWith(letterSpacing: 0),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact tile showing one context value; opens a picker on tap.
class ContextTile extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final VoidCallback onTap;

  const ContextTile({
    super.key,
    required this.label,
    required this.value,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label: $value. Tap to change.',
      child: AnimatedContainer(
        duration: EmoMotion.medium,
        padding: const EdgeInsets.symmetric(horizontal: EmoSpace.sm, vertical: EmoSpace.sm),
        decoration: BoxDecoration(
          color: p.surfaceRaised,
          borderRadius: BorderRadius.circular(EmoRadius.md),
          border: Border.all(color: p.border),
        ),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.text.labelSmall?.copyWith(letterSpacing: 0.2)),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: EmoMotion.fast,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...previous, ?current],
                      ),
                      child: Text(
                        value,
                        key: ValueKey(value),
                        style: context.text.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_more_rounded, size: 18, color: p.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// One choice in an [showOptionSheet] picker.
@immutable
class OptionItem<T> {
  final T value;
  final String label;
  final String emoji;
  final String? caption;

  const OptionItem({required this.value, required this.label, required this.emoji, this.caption});
}

/// Shows a bottom sheet with a list of options and returns the chosen value.
Future<T?> showOptionSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<OptionItem<T>> options,
  required T selected,
  required Color accent,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final p = sheetContext.emo;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(EmoSpace.gutter, 0, EmoSpace.gutter, EmoSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: sheetContext.text.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: EmoSpace.xxs),
                Text(subtitle, style: sheetContext.text.bodySmall),
              ],
              const SizedBox(height: EmoSpace.md),
              for (final o in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: EmoSpace.xs),
                  child: Pressable(
                    onTap: () => Navigator.of(sheetContext).pop(o.value),
                    selected: o.value == selected,
                    semanticLabel: o.label,
                    child: AnimatedContainer(
                      duration: EmoMotion.fast,
                      padding: const EdgeInsets.symmetric(horizontal: EmoSpace.md, vertical: 14),
                      decoration: BoxDecoration(
                        color: o.value == selected ? accent.withValues(alpha: p.isDark ? 0.14 : 0.1) : p.surfaceRaised,
                        borderRadius: BorderRadius.circular(EmoRadius.md),
                        border: Border.all(
                          color: o.value == selected ? accent.withValues(alpha: 0.6) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(o.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: EmoSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.label, style: sheetContext.text.titleSmall),
                                if (o.caption != null)
                                  Text(o.caption!, style: sheetContext.text.bodySmall),
                              ],
                            ),
                          ),
                          if (o.value == selected) Icon(Icons.check_circle_rounded, color: accent, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Centers page content and caps its width on large screens.
class ContentFrame extends StatelessWidget {
  final Widget child;

  const ContentFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: EmoSpace.maxContentWidth),
        child: child,
      ),
    );
  }
}
