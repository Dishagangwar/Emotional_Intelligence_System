import 'package:flutter/material.dart';
import '../../models/prediction_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// One batch prediction; tap to expand the journal text and support message.
class PredictionTile extends StatefulWidget {
  final PredictionResult item;
  final String? journalText;

  const PredictionTile({super.key, required this.item, this.journalText});

  @override
  State<PredictionTile> createState() => _PredictionTileState();
}

class _PredictionTileState extends State<PredictionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final item = widget.item;
    final color = EmotionStyle.of(item.predictedState).color(context);
    final action = ActionStyle.of(item.whatToDo);
    final flagged = item.uncertainFlag == 1;

    return Pressable(
      onTap: () => setState(() => _expanded = !_expanded),
      pressedScale: 0.985,
      haptic: false,
      semanticLabel:
          'Entry ${item.id}, ${EmotionStyle.of(item.predictedState).label}, ${(item.confidence * 100).round()} percent confidence. ${_expanded ? 'Collapse' : 'Expand'}',
      child: EmoCard(
        padding: const EdgeInsets.all(EmoSpace.md),
        child: ExcludeSemantics(
          excluding: !_expanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  StateBadge(state: item.predictedState, dense: true),
                  const SizedBox(width: EmoSpace.xs),
                  Text('#${item.id}', style: context.text.labelSmall?.copyWith(letterSpacing: 0).tabular),
                  const Spacer(),
                  if (flagged) ...[
                    Tooltip(
                      message: 'Low confidence',
                      child: Icon(Icons.help_outline_rounded, size: 16, color: p.caution),
                    ),
                    const SizedBox(width: 6),
                  ],
                  ConfidenceRing(value: item.confidence, color: flagged ? p.caution : color, size: 42, stroke: 3.5),
                ],
              ),
              const SizedBox(height: EmoSpace.sm),
              Row(
                children: [
                  Icon(action.icon, size: 18, color: color),
                  const SizedBox(width: EmoSpace.xs),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: action.label, style: context.text.titleSmall),
                        TextSpan(
                          text: '  ·  ${ActionStyle.timingLabel(item.whenToDo)}',
                          style: context.text.bodySmall,
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IntensityMeter(value: item.predictedIntensity, color: color, height: 14),
                ],
              ),
              AnimatedSize(
                duration: EmoMotion.medium,
                curve: EmoMotion.standard,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: EmoSpace.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.journalText != null && widget.journalText!.isNotEmpty) ...[
                              const Eyebrow('Journal entry'),
                              const SizedBox(height: 4),
                              Text('“${widget.journalText}”',
                                  style: context.text.bodyMedium?.copyWith(color: p.textPrimary)),
                              const SizedBox(height: EmoSpace.sm),
                            ],
                            const Eyebrow('Support message'),
                            const SizedBox(height: 4),
                            Text(item.supportMessage, style: context.text.bodySmall),
                            const SizedBox(height: EmoSpace.sm),
                            Text(
                              'Intensity ${item.predictedIntensity}/5 · Confidence ${(item.confidence * 100).toStringAsFixed(1)}%',
                              style: context.text.labelSmall?.copyWith(letterSpacing: 0.1).tabular,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
