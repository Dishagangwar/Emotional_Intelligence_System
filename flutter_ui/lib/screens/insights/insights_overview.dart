import 'package:flutter/material.dart';
import '../../models/prediction_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// Summary metrics + charts computed from the batch predictions.
class InsightsOverview extends StatelessWidget {
  final List<PredictionResult> predictions;

  const InsightsOverview({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final total = predictions.length;
    final avgConfidence =
        total > 0 ? predictions.map((e) => e.confidence).reduce((a, b) => a + b) / total : 0.0;
    final uncertain = predictions.where((e) => e.uncertainFlag == 1).length;
    final uncertainPct = total > 0 ? (uncertain / total * 100).round() : 0;

    final counts = <String, int>{};
    for (final pr in predictions) {
      final id = EmotionStyle.of(pr.predictedState).id;
      counts[id] = (counts[id] ?? 0) + 1;
    }

    final bins = List<int>.filled(5, 0);
    for (final pr in predictions) {
      final i = (pr.confidence.clamp(0.0, 0.9999) * 5).floor();
      bins[i]++;
    }

    final metrics = [
      _Metric(label: 'Entries', value: '$total', icon: Icons.notes_rounded, color: p.brand),
      _Metric(
        label: 'Avg confidence',
        value: '${(avgConfidence * 100).toStringAsFixed(1)}%',
        icon: Icons.speed_rounded,
        color: EmotionStyle.calm.color(context),
      ),
      _Metric(
        label: 'Low confidence',
        value: '$uncertain',
        suffix: '$uncertainPct%',
        icon: Icons.help_outline_rounded,
        color: p.caution,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            const gap = EmoSpace.xs;
            final cols = c.maxWidth > 420 ? 3 : 2;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < metrics.length; i++)
                  SizedBox(
                    // On narrow screens the third tile spans the full row.
                    width: cols == 2 && i == 2 ? c.maxWidth : w,
                    child: metrics[i],
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: EmoSpace.md),
        EmoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('State distribution', style: context.text.titleMedium),
              const SizedBox(height: 2),
              Text('How often the model predicted each state.', style: context.text.bodySmall),
              const SizedBox(height: EmoSpace.md),
              DistributionBar(counts: counts),
            ],
          ),
        ),
        const SizedBox(height: EmoSpace.md),
        EmoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confidence spread', style: context.text.titleMedium),
              const SizedBox(height: 2),
              Text('Entries per confidence band. Amber bands fall below the 60% threshold.',
                  style: context.text.bodySmall),
              const SizedBox(height: EmoSpace.lg),
              MiniHistogram(
                bins: bins,
                labels: const ['0–20', '20–40', '40–60', '60–80', '80–100'],
                color: EmotionStyle.calm.color(context),
                lowColor: p.caution,
                lowBins: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;

  const _Metric({required this.label, required this.value, required this.icon, required this.color, this.suffix});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return EmoCard(
      padding: const EdgeInsets.all(EmoSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, style: context.text.labelMedium, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: EmoSpace.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: context.text.headlineMedium?.tabular),
                if (suffix != null) ...[
                  const SizedBox(width: 6),
                  Text(suffix!, style: context.text.labelMedium?.copyWith(color: p.textTertiary).tabular),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
