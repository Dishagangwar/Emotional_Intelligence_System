import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

class _Step {
  final int count;
  final String sense;
  final String prompt;
  final IconData icon;
  final EmotionStyle tone;

  const _Step(this.count, this.sense, this.prompt, this.icon, this.tone);
}

/// The 5-4-3-2-1 sensory grounding technique, one step at a time.
class GroundingExercise extends StatefulWidget {
  const GroundingExercise({super.key});

  @override
  State<GroundingExercise> createState() => _GroundingExerciseState();
}

class _GroundingExerciseState extends State<GroundingExercise> {
  static const _steps = [
    _Step(5, 'see', 'Look around slowly. Name five things you can see — a colour, a shape, a patch of light.',
        Icons.visibility_outlined, EmotionStyle.focused),
    _Step(4, 'touch', 'Notice four things you can feel: your clothes, the chair beneath you, the air on your skin.',
        Icons.back_hand_outlined, EmotionStyle.calm),
    _Step(3, 'hear', 'Listen for three sounds, near or far. A fan, traffic, your own breathing.',
        Icons.hearing_outlined, EmotionStyle.restless),
    _Step(2, 'smell', 'Find two things you can smell. Coffee, soap, fresh air — or simply recall a favourite scent.',
        Icons.local_florist_outlined, EmotionStyle.mixed),
    _Step(1, 'taste', 'Notice one thing you can taste. Take a sip of water if it helps.',
        Icons.water_drop_outlined, EmotionStyle.overwhelmed),
  ];

  int _step = 0;
  bool _complete = false;

  void _next() {
    setState(() {
      if (_step < _steps.length - 1) {
        _step++;
      } else {
        _complete = true;
      }
    });
  }

  void _restart() => setState(() {
        _step = 0;
        _complete = false;
      });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    if (_complete) {
      final color = EmotionStyle.calm.color(context);
      return Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: color, size: 40),
          ),
          const SizedBox(height: EmoSpace.lg),
          Text("You're here, now", style: context.text.headlineSmall),
          const SizedBox(height: EmoSpace.xxs),
          Text(
            'Take one slow breath and notice how your body feels compared with a few minutes ago.',
            style: context.text.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EmoSpace.xl),
          EmoButton.secondary(label: 'Go again', icon: Icons.replay_rounded, onPressed: _restart),
        ],
      );
    }

    final s = _steps[_step];
    final color = s.tone.color(context);

    return Column(
      children: [
        // Progress
        Row(
          children: List.generate(_steps.length, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: EmoMotion.medium,
                height: 4,
                margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: i <= _step ? color : p.surfaceRaised,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: EmoSpace.xl),
        AnimatedSwitcher(
          duration: EmoMotion.medium,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: Column(
            key: ValueKey(_step),
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  ),
                  Icon(s.icon, color: color, size: 40),
                ],
              ),
              const SizedBox(height: EmoSpace.lg),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${s.count} ', style: TextStyle(color: color)),
                    TextSpan(text: 'thing${s.count == 1 ? '' : 's'} you can ${s.sense}'),
                  ],
                ),
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: EmoSpace.xs),
              Text(s.prompt, style: context.text.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: EmoSpace.xl),
        Row(
          children: [
            if (_step > 0) ...[
              EmoButton.secondary(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: () => setState(() => _step--),
              ),
              const SizedBox(width: EmoSpace.xs),
            ],
            Expanded(
              child: EmoButton(
                label: _step == _steps.length - 1 ? 'Finish' : 'Next',
                icon: _step == _steps.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: color,
                expand: true,
                onPressed: _next,
              ),
            ),
          ],
        ),
        const SizedBox(height: EmoSpace.sm),
        Text(
          'Step ${_step + 1} of ${_steps.length}',
          style: context.text.labelSmall?.copyWith(letterSpacing: 0.2),
        ),
      ],
    );
  }
}
