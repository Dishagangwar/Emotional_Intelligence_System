import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Horizontal bars showing the model's probability for every state.
/// Bars are sorted high → low and the predicted state is emphasised.
class ProbabilityBars extends StatelessWidget {
  final Map<String, double> probabilities;
  final String highlight;

  const ProbabilityBars({super.key, required this.probabilities, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final entries = probabilities.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: _ProbabilityRow(
              style: EmotionStyle.of(e.key),
              value: e.value,
              emphasised: e.key == highlight,
              palette: p,
            ),
          ),
      ],
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  final EmotionStyle style;
  final double value;
  final bool emphasised;
  final EmoPalette palette;

  const _ProbabilityRow({
    required this.style,
    required this.value,
    required this.emphasised,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = style.colorFor(palette);
    final pct = (value * 100);

    return Semantics(
      label: style.label,
      value: '${pct.toStringAsFixed(0)} percent',
      child: ExcludeSemantics(
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                style.label,
                style: context.text.labelMedium?.copyWith(
                  color: emphasised ? palette.textPrimary : palette.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: _Bar(
                value: value,
                color: emphasised ? color : color.withValues(alpha: 0.4),
                track: palette.surfaceRaised,
                height: 8,
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                pct < 1 ? '<1%' : '${pct.toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: context.text.labelMedium?.copyWith(
                  color: emphasised ? palette.textPrimary : palette.textTertiary,
                ).tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  final double height;

  const _Bar({required this.value, required this.color, required this.track, required this.height});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: EmoMotion.slow,
      curve: EmoMotion.emphasized,
      builder: (context, v, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(height)),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v == 0 ? 0.0 : v.clamp(0.02, 1.0),
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
            ),
          ),
        );
      },
    );
  }
}

/// Five ascending bars visualising intensity on the 1–5 scale.
class IntensityMeter extends StatelessWidget {
  final int value;
  final Color color;
  final double height;

  const IntensityMeter({super.key, required this.value, required this.color, this.height = 18});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Semantics(
      label: 'Intensity',
      value: '$value of 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (i) {
          final active = i < value;
          return AnimatedContainer(
            duration: EmoMotion.medium,
            curve: EmoMotion.standard,
            margin: const EdgeInsets.only(right: 3),
            width: height * 0.32,
            height: height * (0.45 + i * 0.1375),
            decoration: BoxDecoration(
              color: active ? color : p.borderStrong,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

/// A single segmented horizontal bar of category counts with a legend.
class DistributionBar extends StatelessWidget {
  final Map<String, int> counts;

  const DistributionBar({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final ordered = EmotionStyle.all.where((s) => (counts[s.id] ?? 0) > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(EmoRadius.pill),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (var i = 0; i < ordered.length; i++)
                  Expanded(
                    flex: counts[ordered[i].id]!,
                    child: Container(
                      margin: EdgeInsets.only(right: i == ordered.length - 1 ? 0 : 2),
                      color: ordered[i].colorFor(p),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EmoSpace.md),
        Wrap(
          spacing: EmoSpace.md,
          runSpacing: EmoSpace.xs,
          children: [
            for (final s in ordered)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: s.colorFor(p), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(s.label, style: context.text.labelMedium),
                  const SizedBox(width: 4),
                  Text(
                    total == 0 ? '0%' : '${((counts[s.id]! / total) * 100).round()}%',
                    style: context.text.labelMedium?.copyWith(color: p.textTertiary).tabular,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Simple vertical histogram (e.g. confidence spread).
class MiniHistogram extends StatelessWidget {
  final List<int> bins;
  final List<String> labels;
  final Color color;
  final Color? lowColor;
  final int lowBins;
  final double height;

  const MiniHistogram({
    super.key,
    required this.bins,
    required this.labels,
    required this.color,
    this.lowColor,
    this.lowBins = 0,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = bins.fold<int>(0, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < bins.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == bins.length - 1 ? 0 : 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${bins[i]}', style: context.text.labelSmall?.copyWith(letterSpacing: 0).tabular),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: maxV == 0 ? 0 : bins[i] / maxV),
                    duration: EmoMotion.slow,
                    curve: EmoMotion.emphasized,
                    builder: (context, v, _) => Container(
                      height: 4 + (height - 4) * v,
                      decoration: BoxDecoration(
                        color: (i < lowBins ? (lowColor ?? color) : color).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: context.text.labelSmall?.copyWith(fontSize: 10, letterSpacing: 0)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
