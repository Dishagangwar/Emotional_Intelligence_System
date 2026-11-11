import 'package:flutter/material.dart';

import '../../models/prediction_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

enum SaveStatus { idle, saving, saved }

/// Presents a [PredictionResult] from the intelligence engine as a compact,
/// data-first summary: state, key metrics, full probability breakdown and
/// the recommended next step.
class ReadingCard extends StatelessWidget {
  final PredictionResult? result;
  final bool isAnalyzing;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<PracticeTool>? onStartPractice;

  /// Saves this reading to the user's history. `null` hides the action
  /// (e.g. cloud sync not configured).
  final VoidCallback? onSave;
  final SaveStatus saveStatus;

  const ReadingCard({
    super.key,
    required this.result,
    required this.isAnalyzing,
    required this.error,
    required this.onRetry,
    this.onStartPractice,
    this.onSave,
    this.saveStatus = SaveStatus.idle,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    if (error != null) {
      return EmoCard(
        child: ErrorState(
          title: "We couldn't read your state",
          message: error!,
          onRetry: onRetry,
        ),
      );
    }

    final result = this.result;
    if (result == null) {
      return const EmoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 12),
            SizedBox(height: EmoSpace.sm),
            SkeletonBox(width: 180, height: 28),
            SizedBox(height: EmoSpace.md),
            SkeletonBox(height: 76),
          ],
        ),
      );
    }

    final emotion = EmotionStyle.of(result.predictedState);
    final stateColor = emotion.color(context);
    final action = ActionStyle.of(result.whatToDo);

    return Semantics(
      liveRegion: true,
      label:
          'Current reading: ${emotion.label}, ${(result.confidence * 100).round()} percent confidence',
      child: EmoCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedOpacity(
              opacity: isAnalyzing ? 1 : 0,
              duration: EmoMotion.fast,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(EmoRadius.lg),
                ),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(p.brand),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                EmoSpace.md,
                EmoSpace.sm,
                EmoSpace.md,
                EmoSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── State ───────────────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Eyebrow('You seem')),
                      _LiveStatus(updating: isAnalyzing),
                    ],
                  ),
                  const SizedBox(height: EmoSpace.xs),
                  AnimatedSwitcher(
                    duration: EmoMotion.medium,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previous, ?current],
                    ),
                    child: Column(
                      key: ValueKey(emotion.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: stateColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                emotion.label,
                                style: context.text.displaySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          emotion.description,
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: EmoSpace.md),

                  // ── Key metrics ─────────────────────────────────────
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Confidence',
                            value: '${(result.confidence * 100).round()}%',
                            footer: _ThinBar(
                              value: result.confidence,
                              color: result.isUncertain ? p.caution : p.brand,
                            ),
                          ),
                        ),
                        const SizedBox(width: EmoSpace.xs),
                        Expanded(
                          child: _StatTile(
                            label: 'Intensity',
                            value: '${result.predictedIntensity}/5',
                            footer: IntensityMeter(
                              value: result.predictedIntensity,
                              color: stateColor,
                              height: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: EmoSpace.xs),
                        Expanded(
                          child: _StatTile(
                            label: 'When',
                            value: ActionStyle.timingLabel(result.whenToDo),
                            valueSmall: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: EmoMotion.medium,
                    curve: EmoMotion.standard,
                    child: result.isUncertain
                        ? Padding(
                            padding: const EdgeInsets.only(top: EmoSpace.sm),
                            child: InlineNotice(
                              icon: Icons.info_outline_rounded,
                              color: p.caution,
                              title: 'Low confidence',
                              message: "The signals don't clearly point one way. A sentence or two about how you feel will sharpen this reading.",
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),

                  // ── Breakdown ───────────────────────────────────────
                  if (result.stateProbabilities.isNotEmpty) ...[
                    const _SectionDivider(),
                    Text('Signal breakdown', style: context.text.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Model probability for each state',
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: EmoSpace.xs),
                    ProbabilityBars(
                      probabilities: result.stateProbabilities,
                      highlight: result.predictedState,
                    ),
                  ],

                  // ── Recommendation ──────────────────────────────────
                  const _SectionDivider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: p.brand.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(EmoRadius.md),
                        ),
                        child: Icon(action.icon, color: p.brand, size: 21),
                      ),
                      const SizedBox(width: EmoSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('Suggested next step'),
                            const SizedBox(height: 2),
                            Text(action.label, style: context.text.titleMedium),
                            const SizedBox(height: 2),
                            Text(action.blurb, style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (result.supportMessage.isNotEmpty) ...[
                    const SizedBox(height: EmoSpace.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EmoSpace.sm,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: p.surfaceRaised,
                        borderRadius: BorderRadius.circular(EmoRadius.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: p.textTertiary,
                          ),
                          const SizedBox(width: EmoSpace.xs),
                          Expanded(
                            child: Text(
                              result.supportMessage,
                              style: context.text.bodySmall?.copyWith(
                                color: p.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (onStartPractice != null) ...[
                    const SizedBox(height: EmoSpace.md),
                    EmoButton(
                      label: 'Start ${action.practice.label.toLowerCase()}',
                      icon: Icons.play_arrow_rounded,
                      expand: true,
                      onPressed: () => onStartPractice!(action.practice),
                    ),
                  ],
                  if (onSave != null) ...[
                    const SizedBox(height: EmoSpace.xs),
                    Center(
                      child: EmoButton.ghost(
                        label: switch (saveStatus) {
                          SaveStatus.idle => 'Save to history',
                          SaveStatus.saving => 'Saving…',
                          SaveStatus.saved => 'Saved to history',
                        },
                        icon: switch (saveStatus) {
                          SaveStatus.saved =>
                            Icons.check_circle_outline_rounded,
                          _ => Icons.bookmark_add_outlined,
                        },
                        onPressed: saveStatus == SaveStatus.idle && !isAnalyzing
                            ? onSave
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  final bool updating;

  const _LiveStatus({required this.updating});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final color = updating ? p.brand : EmotionStyle.calm.color(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: EmoMotion.fast,
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          updating ? 'Updating' : 'Live',
          style: context.text.labelSmall?.copyWith(
            color: p.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Widget? footer;
  final bool valueSmall;

  const _StatTile({
    required this.label,
    required this.value,
    this.footer,
    this.valueSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        EmoSpace.sm,
        10,
        EmoSpace.sm,
        EmoSpace.sm,
      ),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(EmoRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(letterSpacing: 0.2),
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                (valueSmall
                        ? context.text.titleSmall
                        : context.text.headlineSmall)
                    ?.tabular,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (footer != null) ...[
            const Spacer(),
            const SizedBox(height: 8),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _ThinBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ThinBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: EmoMotion.slow,
      curve: EmoMotion.emphasized,
      builder: (context, v, _) => Container(
        height: 4,
        decoration: BoxDecoration(
          color: p.border,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EmoSpace.md),
      child: Divider(color: context.emo.border, height: 1),
    );
  }
}
