import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Full-screen canvas with two slow-drifting soft glows tinted by the
/// current emotional state. The tint cross-fades whenever the state changes.
class AmbientBackdrop extends StatefulWidget {
  final Color tint;
  final Widget child;

  const AmbientBackdrop({super.key, required this.tint, required this.child});

  @override
  State<AmbientBackdrop> createState() => _AmbientBackdropState();
}

class _AmbientBackdropState extends State<AmbientBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: widget.tint),
            duration: EmoMotion.ambient,
            curve: EmoMotion.standard,
            builder: (context, color, _) => CustomPaint(
              painter: _GlowPainter(
                animation: reduceMotion ? const AlwaysStoppedAnimation<double>(0) : _drift,
                canvasColor: p.canvas,
                tint: color ?? widget.tint,
                strength: p.isDark ? 0.20 : 0.14,
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Animation<double> animation;
  final Color canvasColor;
  final Color tint;
  final double strength;

  _GlowPainter({
    required this.animation,
    required this.canvasColor,
    required this.tint,
    required this.strength,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = canvasColor);

    final t = animation.value * math.pi * 2;
    final w = size.width;
    final h = size.height;

    void glow(Offset center, double radius, double alpha) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [tint.withValues(alpha: alpha), tint.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    glow(Offset(w * (0.18 + 0.06 * math.sin(t)), h * (0.06 + 0.03 * math.cos(t))), w * 0.95, strength);
    glow(Offset(w * (0.95 + 0.05 * math.cos(t)), h * (0.55 + 0.05 * math.sin(t))), w * 0.7, strength * 0.45);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.tint != tint || old.canvasColor != canvasColor || old.strength != strength || old.animation != animation;
}
