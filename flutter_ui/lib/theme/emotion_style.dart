import 'package:flutter/material.dart';

import 'emo_palette.dart';

/// Presentation metadata for each emotional state the model can return.
///
/// This is display-only: it never changes what the model predicts.
@immutable
class EmotionStyle {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color darkColor;
  final Color lightColor;

  const EmotionStyle({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.darkColor,
    required this.lightColor,
  });

  Color colorFor(EmoPalette palette) => palette.isDark ? darkColor : lightColor;
  Color color(BuildContext context) => colorFor(context.emo);

  static const focused = EmotionStyle(
    id: 'focused',
    label: 'Focused',
    description: 'Clear-headed and ready to engage.',
    icon: Icons.center_focus_strong_rounded,
    darkColor: Color(0xFF818CF8),
    lightColor: Color(0xFF4F46E5),
  );
  static const calm = EmotionStyle(
    id: 'calm',
    label: 'Calm',
    description: 'Settled and at ease.',
    icon: Icons.spa_rounded,
    darkColor: Color(0xFF34D399),
    lightColor: Color(0xFF059669),
  );
  static const restless = EmotionStyle(
    id: 'restless',
    label: 'Restless',
    description: 'Energy with nowhere to land yet.',
    icon: Icons.bolt_rounded,
    darkColor: Color(0xFFFBBF24),
    lightColor: Color(0xFFD97706),
  );
  static const overwhelmed = EmotionStyle(
    id: 'overwhelmed',
    label: 'Overwhelmed',
    description: 'Carrying more than feels manageable.',
    icon: Icons.waves_rounded,
    darkColor: Color(0xFFFB7185),
    lightColor: Color(0xFFE11D48),
  );
  static const mixed = EmotionStyle(
    id: 'mixed',
    label: 'Mixed',
    description: 'Pulled in more than one direction.',
    icon: Icons.contrast_rounded,
    darkColor: Color(0xFFA78BFA),
    lightColor: Color(0xFF7C3AED),
  );
  static const neutral = EmotionStyle(
    id: 'neutral',
    label: 'Neutral',
    description: 'Steady, without strong signals.',
    icon: Icons.radio_button_unchecked_rounded,
    darkColor: Color(0xFF94A3B8),
    lightColor: Color(0xFF64748B),
  );

  /// All states in display order.
  static const List<EmotionStyle> all = [
    focused,
    calm,
    restless,
    overwhelmed,
    mixed,
    neutral,
  ];

  static EmotionStyle of(String state) {
    switch (state.toLowerCase().trim()) {
      case 'focused':
        return focused;
      case 'calm':
        return calm;
      case 'restless':
        return restless;
      case 'overwhelmed':
      case 'stressed':
        return overwhelmed;
      case 'mixed':
        return mixed;
      default:
        return neutral;
    }
  }

  static String intensityLabel(int intensity) {
    switch (intensity) {
      case 1:
        return 'Faint';
      case 2:
        return 'Mild';
      case 3:
        return 'Moderate';
      case 4:
        return 'Strong';
      default:
        return intensity >= 5 ? 'Intense' : 'Faint';
    }
  }
}

/// The four guided practices available in the Practice tab.
enum PracticeTool {
  breathing(
    'breathing',
    'Box breathing',
    '4 min',
    Icons.air_rounded,
    EmotionStyle.calm,
  ),
  focus(
    'focus',
    'Focus sprint',
    '15–45 min',
    Icons.timer_outlined,
    EmotionStyle.focused,
  ),
  grounding(
    'grounding',
    '5-4-3-2-1 grounding',
    '3 min',
    Icons.spa_outlined,
    EmotionStyle.mixed,
  ),
  sound(
    'sound',
    'Soundscapes',
    'Ambient',
    Icons.headphones_rounded,
    EmotionStyle.restless,
  );

  final String id;
  final String label;
  final String duration;
  final IconData icon;
  final EmotionStyle tone;

  const PracticeTool(this.id, this.label, this.duration, this.icon, this.tone);

  static PracticeTool fromId(String id) => PracticeTool.values.firstWhere(
    (t) => t.id == id,
    orElse: () => PracticeTool.breathing,
  );
}

/// Presentation metadata for the decision-engine actions (`what_to_do`).
@immutable
class ActionStyle {
  final String label;
  final String blurb;
  final IconData icon;

  /// The Practice tool this action opens.
  final PracticeTool practice;

  const ActionStyle(this.label, this.blurb, this.icon, this.practice);

  static ActionStyle of(String action) {
    switch (action) {
      case 'box_breathing':
        return const ActionStyle(
          'Box breathing',
          'Four slow counts in, hold, out, hold. Calms the nervous system fast.',
          Icons.air_rounded,
          PracticeTool.breathing,
        );
      case 'deep_work':
        return const ActionStyle(
          'Deep work',
          'Protect a block of uninterrupted time while your mind is clear.',
          Icons.psychology_rounded,
          PracticeTool.focus,
        );
      case 'grounding':
        return const ActionStyle(
          'Grounding',
          'Bring attention back to your senses to settle racing thoughts.',
          Icons.spa_rounded,
          PracticeTool.grounding,
        );
      case 'sound_therapy':
        return const ActionStyle(
          'Sound therapy',
          'Let calming ambience slow things down before rest.',
          Icons.headphones_rounded,
          PracticeTool.sound,
        );
      case 'movement':
        return const ActionStyle(
          'Movement',
          'A short walk or stretch to discharge restless energy.',
          Icons.directions_walk_rounded,
          PracticeTool.grounding,
        );
      case 'journaling':
        return const ActionStyle(
          'Journaling',
          'Write it out to untangle feelings that pull different ways.',
          Icons.edit_note_rounded,
          PracticeTool.grounding,
        );
      case 'rest':
        return const ActionStyle(
          'Rest',
          'Your energy is low. Step away and recharge before pushing on.',
          Icons.bedtime_rounded,
          PracticeTool.grounding,
        );
      case 'light_planning':
        return const ActionStyle(
          'Light planning',
          'Sketch a few gentle next steps without committing to everything.',
          Icons.checklist_rounded,
          PracticeTool.grounding,
        );
      default:
        return ActionStyle(
          _titleCase(action),
          'A small step to support your current state.',
          Icons.lightbulb_outline_rounded,
          PracticeTool.grounding,
        );
    }
  }

  static String timingLabel(String when) {
    switch (when) {
      case 'now':
        return 'Right now';
      case 'within_15_min':
        return 'Within 15 min';
      case 'later_today':
        return 'Later today';
      case 'tonight':
        return 'Tonight';
      default:
        return _titleCase(when);
    }
  }

  static String _titleCase(String raw) {
    final s = raw.replaceAll('_', ' ').trim();
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
