import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Animated circular gauge showing model confidence (0–1).
class ConfidenceRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final double stroke;
  final String caption;

  const ConfidenceRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 84,
    this.stroke = 7,
    this.caption = 'confidence',
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final clamped = value.clamp(0.0, 1.0);

    return Semantics(
      label: 'Model confidence',
      value: '${(clamped * 100).round()} percent',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: clamped),
        duration: EmoMotion.slow,
        curve: EmoMotion.emphasized,
        builder: (context, v, _) {
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                value: v,
                color: color,
                track: p.isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.06),
                stroke: stroke,
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(v * 100).round()}%',
                        style: context.text.titleLarge
                            ?.copyWith(
                              fontSize: size * 0.22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1,
                            )
                            .tabular,
                      ),
                      if (size >= 72) ...[
                        const SizedBox(height: 3),
                        Text(
                          caption,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    const start = -math.pi / 2;

    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (value <= 0) return;
    final sweep = math.pi * 2 * value;
    canvas.drawArc(
      arcRect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
