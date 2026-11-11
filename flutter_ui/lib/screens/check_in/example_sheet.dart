import 'package:flutter/material.dart';

import '../../models/reflection_input.dart';
import '../../services/data_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';
import 'context_options.dart';

/// Bottom sheet listing the curated test-set scenarios.
Future<ReflectionInput?> showExampleSheet(BuildContext context) {
  return showModalBottomSheet<ReflectionInput>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final p = sheetContext.emo;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            EmoSpace.gutter,
            0,
            EmoSpace.gutter,
            EmoSpace.xl,
          ),
          children: [
            Text('Try an example', style: sheetContext.text.headlineSmall),
            const SizedBox(height: EmoSpace.xxs),
            Text(
              'Real entries from the test dataset. Loading one fills in the text and context.',
              style: sheetContext.text.bodySmall,
            ),
            const SizedBox(height: EmoSpace.md),
            for (final s in DataRepository.sampleScenarios)
              Padding(
                padding: const EdgeInsets.only(bottom: EmoSpace.xs),
                child: Pressable(
                  onTap: () => Navigator.of(sheetContext).pop(s),
                  semanticLabel: 'Example: ${s.journalText}',
                  child: Container(
                    padding: const EdgeInsets.all(EmoSpace.md),
                    decoration: BoxDecoration(
                      color: p.surfaceRaised,
                      borderRadius: BorderRadius.circular(EmoRadius.md),
                      border: Border.all(color: p.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“${s.journalText}”',
                          style: sheetContext.text.bodyMedium?.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: EmoSpace.xs),
                        Text(
                          'Stress ${s.stressLevel}/5 · Energy ${s.energyLevel}/5 · Sleep ${ContextOptions.sleepLabel(s.sleepHours)} · '
                          '${ContextOptions.find(
                            ContextOptions.timeOfDay,
                            s.timeOfDay,
                            fallback: OptionItem(value: s.timeOfDay, label: s.timeOfDay, emoji: ''),
                          ).label}',
                          style: sheetContext.text.labelSmall?.copyWith(
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
