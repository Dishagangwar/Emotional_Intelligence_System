import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// Deep-work countdown with 15 / 25 / 45 minute presets.
class FocusTimer extends StatefulWidget {
  final int initialMinutes;

  const FocusTimer({super.key, this.initialMinutes = 25});

  @override
  State<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  late int _totalSeconds = widget.initialMinutes * 60;
  late int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  bool _isRunning = false;

  bool get _finished => _remainingSeconds == 0;

  void _toggle() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
        if (_remainingSeconds == 0) {
          _timer?.cancel();
          _isRunning = false;
          HapticFeedback.mediumImpact();
        }
      });
    });
  }

  void _reset([int? mins]) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (mins != null) _totalSeconds = mins * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String _format(int sec) =>
      '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final color = p.brand;
    final elapsed = _totalSeconds > 0
        ? 1 - (_remainingSeconds / _totalSeconds)
        : 0.0;

    return Column(
      children: [
        Text(
          _finished
              ? 'Sprint complete'
              : (_isRunning ? 'In the zone' : 'Choose a sprint length'),
          style: context.text.headlineSmall,
        ),
        const SizedBox(height: EmoSpace.xxs),
        Text(
          _finished
              ? 'Take a short break before the next one.'
              : 'Silence notifications and commit to one task.',
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EmoSpace.lg),
        Wrap(
          spacing: EmoSpace.xs,
          alignment: WrapAlignment.center,
          children: [
            for (final m in const [15, 25, 45])
              EmoChip(
                label: '$m min',
                selected: _totalSeconds == m * 60,
                onTap: () => _reset(m),
              ),
          ],
        ),
        const SizedBox(height: EmoSpace.xl),
        Semantics(
          label: 'Time remaining',
          value: _format(_remainingSeconds),
          child: ExcludeSemantics(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: elapsed),
                      duration: EmoMotion.slow,
                      builder: (context, v, _) => CircularProgressIndicator(
                        value: _finished ? 1 : v,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: p.surfaceRaised,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_finished)
                        Icon(Icons.check_rounded, size: 56, color: color)
                      else
                        Text(
                          _format(_remainingSeconds),
                          style: context.text.displayMedium?.tabular,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _finished
                            ? 'Done'
                            : (_isRunning ? 'Focusing' : 'Paused'),
                        style: context.text.labelMedium?.copyWith(
                          color: p.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: EmoSpace.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_finished)
              EmoButton(
                label: 'Start another',
                icon: Icons.replay_rounded,
                onPressed: () => _reset(),
              )
            else if (_isRunning)
              EmoButton.secondary(
                label: 'Pause',
                icon: Icons.pause_rounded,
                onPressed: _toggle,
              )
            else
              EmoButton(
                label: _remainingSeconds < _totalSeconds
                    ? 'Resume'
                    : 'Start sprint',
                icon: Icons.play_arrow_rounded,
                onPressed: _toggle,
              ),
            if (!_finished && _remainingSeconds < _totalSeconds) ...[
              const SizedBox(width: EmoSpace.xs),
              IconButton(
                onPressed: () => _reset(),
                tooltip: 'Reset timer',
                icon: Icon(Icons.refresh_rounded, color: p.textTertiary),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
