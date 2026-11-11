import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

enum BreathingPhase { inhale, holdIn, exhale, holdOut }

/// 4-4-4-4 box breathing with an expanding / contracting square.
class BreathingExercise extends StatefulWidget {
  final VoidCallback? onComplete;

  /// Rounds after which a completion message is shown (breathing continues).
  final int targetRounds;

  const BreathingExercise({super.key, this.onComplete, this.targetRounds = 4});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise> with SingleTickerProviderStateMixin {
  static const int _phaseSeconds = 4;

  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: _phaseSeconds));
  Timer? _timer;

  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _secondsLeft = _phaseSeconds;
  int _cyclesCompleted = 0;
  bool _isRunning = false;
  bool _started = false;

  void _start() {
    setState(() {
      _isRunning = true;
      _started = true;
      _currentPhase = BreathingPhase.inhale;
      _secondsLeft = _phaseSeconds;
      _cyclesCompleted = 0;
    });
    _animationController.forward(from: 0.0);
    _startTicker();
  }

  void _resume() {
    setState(() => _isRunning = true);
    if (_currentPhase == BreathingPhase.inhale) _animationController.forward();
    if (_currentPhase == BreathingPhase.exhale) _animationController.reverse();
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) _advancePhase();
      });
    });
  }

  void _advancePhase() {
    _secondsLeft = _phaseSeconds;
    HapticFeedback.lightImpact();
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        _currentPhase = BreathingPhase.holdIn;
      case BreathingPhase.holdIn:
        _currentPhase = BreathingPhase.exhale;
        _animationController.reverse(from: 1.0);
      case BreathingPhase.exhale:
        _currentPhase = BreathingPhase.holdOut;
      case BreathingPhase.holdOut:
        _currentPhase = BreathingPhase.inhale;
        _cyclesCompleted++;
        if (_cyclesCompleted == widget.targetRounds) widget.onComplete?.call();
        _animationController.forward(from: 0.0);
    }
  }

  void _pause() {
    _timer?.cancel();
    _animationController.stop();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    _animationController.reset();
    setState(() {
      _isRunning = false;
      _started = false;
      _currentPhase = BreathingPhase.inhale;
      _secondsLeft = _phaseSeconds;
      _cyclesCompleted = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  static const _phaseNames = {
    BreathingPhase.inhale: 'Breathe in',
    BreathingPhase.holdIn: 'Hold',
    BreathingPhase.exhale: 'Breathe out',
    BreathingPhase.holdOut: 'Rest',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final color = EmotionStyle.calm.color(context);
    final done = _cyclesCompleted >= widget.targetRounds;

    return Column(
      children: [
        Text(
          done ? 'Nicely done' : (_started ? _phaseNames[_currentPhase]! : 'Find a comfortable seat'),
          style: context.text.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EmoSpace.xxs),
        Text(
          done
              ? '${widget.targetRounds} rounds complete. Keep going as long as it helps.'
              : 'Follow the square: four counts each side.',
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EmoSpace.xl),
        Semantics(
          liveRegion: true,
          label: _started ? '${_phaseNames[_currentPhase]}, $_secondsLeft seconds' : 'Ready',
          child: ExcludeSemantics(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                final double v;
                switch (_currentPhase) {
                  case BreathingPhase.holdIn:
                    v = 1.0;
                  case BreathingPhase.holdOut:
                    v = 0.0;
                  default:
                    v = Curves.easeInOut.transform(_animationController.value);
                }
                final scale = 0.62 + v * 0.38;
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Guide outline at full size.
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48),
                          border: Border.all(color: color.withValues(alpha: 0.18), width: 1.5),
                        ),
                      ),
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0.18)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: _isRunning ? 0.35 : 0.12),
                                blurRadius: 48,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        _started ? '$_secondsLeft' : '$_phaseSeconds',
                        style: context.text.displayLarge?.tabular,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: EmoSpace.xl),
        _PhaseSteps(current: _started ? _currentPhase : null, color: color),
        const SizedBox(height: EmoSpace.md),
        Text(
          'Rounds completed: $_cyclesCompleted',
          style: context.text.labelMedium?.copyWith(color: p.textTertiary).tabular,
        ),
        const SizedBox(height: EmoSpace.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRunning)
              EmoButton.secondary(label: 'Pause', icon: Icons.pause_rounded, onPressed: _pause)
            else
              EmoButton(
                label: _started ? 'Resume' : 'Begin',
                icon: Icons.play_arrow_rounded,
                color: color,
                onPressed: _started ? _resume : _start,
              ),
            if (_started) ...[
              const SizedBox(width: EmoSpace.xs),
              IconButton(
                onPressed: _reset,
                tooltip: 'Restart',
                icon: Icon(Icons.refresh_rounded, color: p.textTertiary),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PhaseSteps extends StatelessWidget {
  final BreathingPhase? current;
  final Color color;

  const _PhaseSteps({required this.current, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    const labels = ['In', 'Hold', 'Out', 'Rest'];
    return Row(
      children: List.generate(4, (i) {
        final active = current?.index == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 3 ? 0 : 6),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: EmoMotion.medium,
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? color : p.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: context.text.labelSmall?.copyWith(
                    color: active ? p.textPrimary : p.textTertiary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
