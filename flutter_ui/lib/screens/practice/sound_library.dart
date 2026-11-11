import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// Ambient soundscape catalogue.
///
/// Audio playback isn't implemented in the app yet, so this screen says so
/// plainly instead of pretending a track is playing.
class SoundLibrary extends StatelessWidget {
  const SoundLibrary({super.key});

  static const _sounds = [
    ('🌊', 'Ocean tide', 'Slow surf for winding down', EmotionStyle.focused),
    ('🌧️', 'Night rain', 'Soft, steady rainfall', EmotionStyle.mixed),
    ('🌲', 'Pine forest', 'Wind through trees and distant birds', EmotionStyle.calm),
    ('🏔️', 'Alpine stream', 'Clear running water', EmotionStyle.restless),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InlineNotice(
          icon: Icons.schedule_rounded,
          color: p.brand,
          title: 'Playback coming soon',
          message: 'Soundscapes are being prepared. Until then, try box breathing or grounding.',
        ),
        const SizedBox(height: EmoSpace.md),
        for (final (emoji, name, desc, tone) in _sounds)
          Padding(
            padding: const EdgeInsets.only(bottom: EmoSpace.xs),
            child: Container(
              padding: const EdgeInsets.all(EmoSpace.sm),
              decoration: BoxDecoration(
                color: p.surfaceRaised,
                borderRadius: BorderRadius.circular(EmoRadius.md),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tone.color(context).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(EmoRadius.sm),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: EmoSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: context.text.titleSmall),
                        const SizedBox(height: 2),
                        Text(desc, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  Text('Soon', style: context.text.labelSmall),
                  const SizedBox(width: EmoSpace.xs),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
