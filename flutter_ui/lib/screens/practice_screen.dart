import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/ui.dart';
import 'practice/breathing_exercise.dart';
import 'practice/focus_timer.dart';
import 'practice/grounding_exercise.dart';
import 'practice/sound_library.dart';

/// Practice tab: guided exercises the decision engine recommends.
class PracticeScreen extends StatefulWidget {
  final String initialTool;

  const PracticeScreen({super.key, this.initialTool = 'breathing'});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late PracticeTool _selected = PracticeTool.fromId(widget.initialTool);

  Widget _body(PracticeTool tool) {
    switch (tool) {
      case PracticeTool.breathing:
        return const BreathingExercise();
      case PracticeTool.focus:
        return const FocusTimer();
      case PracticeTool.grounding:
        return const GroundingExercise();
      case PracticeTool.sound:
        return const SoundLibrary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _selected.tone.color(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(EmoSpace.gutter, EmoSpace.xs, EmoSpace.gutter, EmoSpace.navClearance),
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              eyebrow: 'Practice',
              title: 'Reset your state',
              subtitle: 'Short, guided exercises matched to how you feel.',
            ),
            const SizedBox(height: EmoSpace.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 520 ? 4 : 2;
                const gap = EmoSpace.xs;
                final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final t in PracticeTool.values)
                      SizedBox(
                        width: width,
                        child: _ToolTile(
                          tool: t,
                          selected: t == _selected,
                          onTap: () => setState(() => _selected = t),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: EmoSpace.lg),
            EmoCard(
              accent: color,
              padding: const EdgeInsets.fromLTRB(EmoSpace.lg, EmoSpace.xl, EmoSpace.lg, EmoSpace.lg),
              child: AnimatedSwitcher(
                duration: EmoMotion.medium,
                switchInCurve: EmoMotion.standard,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: Tween(begin: 0.98, end: 1.0).animate(anim), child: child),
                ),
                child: KeyedSubtree(key: ValueKey(_selected), child: _body(_selected)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final PracticeTool tool;
  final bool selected;
  final VoidCallback onTap;

  const _ToolTile({required this.tool, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final color = tool.tone.color(context);

    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: tool.label,
      child: AnimatedContainer(
        duration: EmoMotion.medium,
        curve: EmoMotion.standard,
        padding: const EdgeInsets.all(EmoSpace.md),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: p.isDark ? 0.14 : 0.1) : p.surface,
          borderRadius: BorderRadius.circular(EmoRadius.lg),
          border: Border.all(color: selected ? color.withValues(alpha: 0.55) : p.border),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: EmoMotion.medium,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected ? color : color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(EmoRadius.sm),
                ),
                child: Icon(tool.icon, size: 20, color: selected ? p.onAccent : color),
              ),
              const SizedBox(height: EmoSpace.sm),
              Text(tool.label, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(tool.duration, style: context.text.labelSmall?.copyWith(letterSpacing: 0.1)),
            ],
          ),
        ),
      ),
    );
  }
}
