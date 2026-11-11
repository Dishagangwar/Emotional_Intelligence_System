import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';
import 'context_options.dart';

/// Contextual signals (stress, energy, sleep, time, expression, ambience,
/// yesterday's mood) that the engine combines with the journal text.
class ContextPanel extends StatelessWidget {
  final int stressLevel;
  final int energyLevel;
  final double sleepHours;
  final String timeOfDay;
  final String faceEmotionHint;
  final String ambienceType;
  final String previousDayMood;
  final Color accent;

  final ValueChanged<int> onStressChanged;
  final ValueChanged<int> onEnergyChanged;
  final ValueChanged<double> onSleepChanged;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onFaceChanged;
  final ValueChanged<String> onAmbienceChanged;
  final ValueChanged<String> onPreviousMoodChanged;

  const ContextPanel({
    super.key,
    required this.stressLevel,
    required this.energyLevel,
    required this.sleepHours,
    required this.timeOfDay,
    required this.faceEmotionHint,
    required this.ambienceType,
    required this.previousDayMood,
    required this.accent,
    required this.onStressChanged,
    required this.onEnergyChanged,
    required this.onSleepChanged,
    required this.onTimeChanged,
    required this.onFaceChanged,
    required this.onAmbienceChanged,
    required this.onPreviousMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    final time = ContextOptions.find(ContextOptions.timeOfDay, timeOfDay,
        fallback: OptionItem(value: timeOfDay, label: timeOfDay, emoji: '🕒'));
    final face = ContextOptions.find(ContextOptions.faceHint, faceEmotionHint,
        fallback: OptionItem(value: faceEmotionHint, label: faceEmotionHint, emoji: '🙂'));
    final amb = ContextOptions.find(ContextOptions.ambience, ambienceType,
        fallback: OptionItem(value: ambienceType, label: ambienceType, emoji: '🎧'));
    final prev = ContextOptions.find(ContextOptions.previousMood, previousDayMood,
        fallback: OptionItem(value: previousDayMood, label: previousDayMood, emoji: '⚪'));
    final sleep = ContextOptions.find(ContextOptions.sleep, sleepHours,
        fallback: OptionItem(value: sleepHours, label: ContextOptions.sleepLabel(sleepHours), emoji: '🌙'));

    final tiles = <Widget>[
      ContextTile(
        label: 'Sleep',
        value: ContextOptions.sleepLabel(sleepHours),
        emoji: sleep.emoji,
        onTap: () async {
          final v = await showOptionSheet<double>(
            context: context,
            title: 'How long did you sleep?',
            options: ContextOptions.sleep,
            selected: sleepHours,
            accent: accent,
          );
          if (v != null) onSleepChanged(v);
        },
      ),
      ContextTile(
        label: 'Time of day',
        value: time.label,
        emoji: time.emoji,
        onTap: () async {
          final v = await showOptionSheet<String>(
            context: context,
            title: 'When is this?',
            options: ContextOptions.timeOfDay,
            selected: timeOfDay,
            accent: accent,
          );
          if (v != null) onTimeChanged(v);
        },
      ),
      ContextTile(
        label: 'Expression',
        value: face.label,
        emoji: face.emoji,
        onTap: () async {
          final v = await showOptionSheet<String>(
            context: context,
            title: 'How does your face feel?',
            subtitle: 'A quick body check — no camera involved.',
            options: ContextOptions.faceHint,
            selected: faceEmotionHint,
            accent: accent,
          );
          if (v != null) onFaceChanged(v);
        },
      ),
      ContextTile(
        label: 'Yesterday',
        value: prev.label,
        emoji: prev.emoji,
        onTap: () async {
          final v = await showOptionSheet<String>(
            context: context,
            title: 'How was yesterday?',
            options: ContextOptions.previousMood,
            selected: previousDayMood,
            accent: accent,
          );
          if (v != null) onPreviousMoodChanged(v);
        },
      ),
      ContextTile(
        label: 'Session ambience',
        value: amb.label,
        emoji: amb.emoji,
        onTap: () async {
          final v = await showOptionSheet<String>(
            context: context,
            title: 'Which ambience did you use?',
            options: ContextOptions.ambience,
            selected: ambienceType,
            accent: accent,
          );
          if (v != null) onAmbienceChanged(v);
        },
      ),
    ];

    return EmoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LevelSelector(
            label: 'Stress',
            icon: Icons.monitor_heart_outlined,
            value: stressLevel,
            color: EmotionStyle.of(stressLevel >= 4 ? 'overwhelmed' : 'calm').color(context),
            lowLabel: 'At ease',
            highLabel: 'Under pressure',
            onChanged: onStressChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: EmoSpace.lg),
            child: Divider(color: p.border),
          ),
          LevelSelector(
            label: 'Energy',
            icon: Icons.bolt_rounded,
            value: energyLevel,
            color: EmotionStyle.focused.color(context),
            lowLabel: 'Drained',
            highLabel: 'Charged',
            onChanged: onEnergyChanged,
          ),
          const SizedBox(height: EmoSpace.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 460 ? 3 : 2;
              const gap = EmoSpace.xs;
              final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [for (final t in tiles) SizedBox(width: width, child: t)],
              );
            },
          ),
        ],
      ),
    );
  }
}
