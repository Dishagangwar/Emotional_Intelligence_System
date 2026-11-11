import 'package:flutter/material.dart';
import '../../models/prediction_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// Presents a [PredictionResult] from the intelligence engine:
/// state, confidence, intensity, the full probability breakdown and the
/// recommended next step.
class ReadingCard extends StatefulWidget {
  final PredictionResult? result;
  final bool isAnalyzing;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<PracticeTool>? onStartPractice;

  const ReadingCard({
    super.key,
    required this.result,
    required this.isAnalyzing,
    required this.error,
    required this.onRetry,
    this.onStartPractice,
  });

  @override
  State<ReadingCard> createState() => _ReadingCardState();
}

class _ReadingCardState extends State<ReadingCard> {
  bool _showBreakdown = false;

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    if (widget.error != null) {
      return EmoCard(
        child: ErrorState(
          title: "We couldn't read your state",
          message: widget.error!,
          onRetry: widget.onRetry,
        ),
      );
    }

    final result = widget.result;
    if (result == null) {
      return const EmoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 14),
            SizedBox(height: EmoSpace.sm),
            SkeletonBox(width: 200, height: 32),
            SizedBox(height: EmoSpace.lg),
            SkeletonBox(height: 72),
          ],
        ),
      );
    }

    final emotion = EmotionStyle.of(result.predictedState);
    final color = emotion.color(context);
    final action = ActionStyle.of(result.whatToDo);
    final hasBreakdown = result.stateProbabilities.isNotEmpty;

    return Semantics(
      liveRegion: true,
      label: 'Current reading: ${emotion.label}, ${(result.confidence * 100).round()} percent confidence',
      child: EmoCard(
        accent: color,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thin progress line while the engine recomputes.
            AnimatedOpacity(
              opacity: widget.isAnalyzing ? 1 : 0,
              duration: EmoMotion.fast,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(EmoRadius.lg)),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: widget.isAnalyzing ? 0.6 : 1,
              duration: EmoMotion.fast,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(EmoSpace.lg, EmoSpace.md, EmoSpace.lg, EmoSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Headline(emotion: emotion, color: color, confidence: result.confidence),
                    const SizedBox(height: EmoSpace.lg),
                    _IntensityRow(intensity: result.predictedIntensity, color: color),
                    AnimatedSize(
                      duration: EmoMotion.medium,
                      curve: EmoMotion.standard,
                      child: result.isUncertain
                          ? Padding(
                              padding: const EdgeInsets.only(top: EmoSpace.md),
                              child: InlineNotice(
                                icon: Icons.info_outline_rounded,
                                color: p.caution,
                                title: 'Low confidence',
                                message:
                                    "The signals don't clearly point one way. Describing how you feel in a sentence or two will sharpen this reading.",
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    if (hasBreakdown) ...[
                      const SizedBox(height: EmoSpace.sm),
                      _BreakdownToggle(
                        expanded: _showBreakdown,
                        onTap: () => setState(() => _showBreakdown = !_showBreakdown),
                      ),
                      AnimatedSize(
                        duration: EmoMotion.medium,
                        curve: EmoMotion.standard,
                        alignment: Alignment.topCenter,
                        child: _showBreakdown
                            ? Padding(
                                padding: const EdgeInsets.only(top: EmoSpace.xs),
                                child: ProbabilityBars(
                                  probabilities: result.stateProbabilities,
                                  highlight: result.predictedState,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                    const SizedBox(height: EmoSpace.md),
                    Divider(color: p.border),
                    const SizedBox(height: EmoSpace.lg),
                    _Recommendation(action: action, whenToDo: result.whenToDo, color: color),
                    if (result.supportMessage.isNotEmpty) ...[
                      const SizedBox(height: EmoSpace.md),
                      _SupportQuote(message: result.supportMessage, color: color),
                    ],
                    if (widget.onStartPractice != null) ...[
                      const SizedBox(height: EmoSpace.lg),
                      EmoButton(
                        label: 'Start ${action.practice.label.toLowerCase()}',
                        icon: Icons.play_arrow_rounded,
                        color: color,
                        expand: true,
                        onPressed: () => widget.onStartPractice!(action.practice),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final EmotionStyle emotion;
  final Color color;
  final double confidence;

  const _Headline({required this.emotion, required this.color, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: EmoMotion.medium,
            switchInCurve: EmoMotion.standard,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(emotion.id),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('You seem'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(emotion.icon, color: color, size: 26),
                    const SizedBox(width: EmoSpace.xs),
                    Flexible(
                      child: Text(
                        emotion.label,
                        style: context.text.displaySmall?.copyWith(color: color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(emotion.description, style: context.text.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(width: EmoSpace.md),
        ConfidenceRing(value: confidence, color: color, size: 84),
      ],
    );
  }
}

class _IntensityRow extends StatelessWidget {
  final int intensity;
  final Color color;

  const _IntensityRow({required this.intensity, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EmoSpace.md, vertical: EmoSpace.sm),
      decoration: BoxDecoration(
        color: p.surfaceRaised.withValues(alpha: p.isDark ? 0.7 : 1),
        borderRadius: BorderRadius.circular(EmoRadius.md),
      ),
      child: Row(
        children: [
          IntensityMeter(value: intensity, color: color),
          const SizedBox(width: EmoSpace.sm),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Intensity  ', style: context.text.labelMedium),
                TextSpan(
                  text: '${EmotionStyle.intensityLabel(intensity)} · $intensity/5',
                  style: context.text.labelMedium?.copyWith(color: p.textPrimary).tabular,
                ),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _BreakdownToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Pressable(
      onTap: onTap,
      semanticLabel: expanded ? 'Hide signal breakdown' : 'Show signal breakdown',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: EmoSpace.xs),
        child: Row(
          children: [
            Icon(Icons.bar_chart_rounded, size: 18, color: p.textTertiary),
            const SizedBox(width: EmoSpace.xs),
            Expanded(
              child: Text(
                'How the model weighed each state',
                style: context.text.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: EmoMotion.medium,
              child: Icon(Icons.expand_more_rounded, size: 20, color: p.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recommendation extends StatelessWidget {
  final ActionStyle action;
  final String whenToDo;
  final Color color;

  const _Recommendation({required this.action, required this.whenToDo, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Suggested next step'),
        const SizedBox(height: EmoSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: EmoMotion.medium,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: p.isDark ? 0.14 : 0.1),
                borderRadius: BorderRadius.circular(EmoRadius.md),
              ),
              child: Icon(action.icon, color: color, size: 24),
            ),
            const SizedBox(width: EmoSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: EmoSpace.xs,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(action.label, style: context.text.titleLarge),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: p.surfaceRaised,
                          borderRadius: BorderRadius.circular(EmoRadius.pill),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 13, color: p.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              ActionStyle.timingLabel(whenToDo),
                              style: context.text.labelMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(action.blurb, style: context.text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportQuote extends StatelessWidget {
  final String message;
  final Color color;

  const _SupportQuote({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return ClipRRect(
      borderRadius: BorderRadius.circular(EmoRadius.md),
      child: Container(
        color: p.surfaceSunken.withValues(alpha: p.isDark ? 0.8 : 1),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(EmoSpace.md, EmoSpace.sm, EmoSpace.md, EmoSpace.sm),
                  child: Text(
                    message,
                    style: context.text.bodyMedium?.copyWith(
                      color: p.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
