import 'dart:async';

import 'package:flutter/material.dart';

import '../models/prediction_result.dart';
import '../models/reflection_input.dart';
import '../services/intelligence_engine.dart';
import '../theme/app_theme.dart' show EmoSpace;
import '../widgets/ui/ui.dart';
import 'check_in/context_panel.dart';
import 'check_in/example_sheet.dart';
import 'check_in/journal_card.dart';
import 'check_in/reading_card.dart';

/// Check-in tab: the user writes a reflection, adjusts context, and gets a
/// live reading from [IntelligenceEngine].
class CheckInScreen extends StatefulWidget {
  final ValueChanged<String>? onNavigateToTool;
  final ValueChanged<String>? onEmotionChanged;

  const CheckInScreen({
    super.key,
    this.onNavigateToTool,
    this.onEmotionChanged,
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final TextEditingController _textController = TextEditingController();

  String _ambienceType = 'ocean';
  double _sleepHours = 7.0;
  int _energyLevel = 3;
  int _stressLevel = 3;
  String _timeOfDay = 'afternoon';
  String _faceEmotionHint = 'calm_face';
  String _previousDayMood = 'neutral';

  PredictionResult? _currentResult;
  String? _error;
  bool _isAnalyzing = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textController.text = "The ocean ambience helped me stop drifting and concentrate on my next steps. My to-do list feels less chaotic.";
    _runAnalysis(immediate: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  ReflectionInput _buildInput() => ReflectionInput(
    journalText: _textController.text,
    ambienceType: _ambienceType,
    sleepHours: _sleepHours,
    energyLevel: _energyLevel,
    stressLevel: _stressLevel,
    timeOfDay: _timeOfDay,
    faceEmotionHint: _faceEmotionHint,
    previousDayMood: _previousDayMood,
  );

  void _applyPrediction(ReflectionInput input) {
    try {
      final res = IntelligenceEngine.predict(input);
      setState(() {
        _currentResult = res;
        _error = null;
        _isAnalyzing = false;
      });
      widget.onEmotionChanged?.call(res.predictedState);
    } catch (e) {
      setState(() {
        _error = 'Something went wrong while analysing this entry. Your text is safe — try again.';
        _isAnalyzing = false;
      });
    }
  }

  /// Same inference flow as before: immediate on load / preset, debounced
  /// (250 ms) while the user types or tweaks context.
  void _runAnalysis({bool immediate = false}) {
    _debounceTimer?.cancel();
    final input = _buildInput();

    if (immediate) {
      _applyPrediction(input);
      return;
    }

    setState(() => _isAnalyzing = true);
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _applyPrediction(input);
    });
  }

  void _loadSample(ReflectionInput sample) {
    setState(() {
      _textController.text = sample.journalText;
      _ambienceType = sample.ambienceType;
      _sleepHours = sample.sleepHours;
      _energyLevel = sample.energyLevel;
      _stressLevel = sample.stressLevel;
      _timeOfDay = sample.timeOfDay;
      _faceEmotionHint = sample.faceEmotionHint;
      _previousDayMood = sample.previousDayMood;
    });
    _runAnalysis(immediate: true);
  }

  void _update(VoidCallback change) {
    setState(change);
    _runAnalysis();
  }

  Future<void> _openExamples() async {
    final sample = await showExampleSheet(context);
    if (sample != null && mounted) _loadSample(sample);
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Late night check-in';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 22) return 'Good evening';
    return 'Late night check-in';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        EmoSpace.gutter,
        EmoSpace.xs,
        EmoSpace.gutter,
        EmoSpace.navClearance,
      ),
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: _greeting(),
              title: 'How are you, really?',
              subtitle: 'Write freely. Emostate analyses your words and context in real time.',
            ),
            const SizedBox(height: EmoSpace.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: EmoButton.ghost(
                label: 'Try an example',
                icon: Icons.auto_awesome_outlined,
                onPressed: _openExamples,
              ),
            ),
            const SizedBox(height: EmoSpace.xs),
            JournalCard(
              controller: _textController,
              isAnalyzing: _isAnalyzing,
              onChanged: (_) => _runAnalysis(),
              onClear: () {
                _textController.clear();
                _runAnalysis();
              },
            ),
            const SizedBox(height: EmoSpace.xl),
            const SectionHeader(
              title: 'Context',
              subtitle: 'Signals the model weighs alongside your words.',
            ),
            ContextPanel(
              stressLevel: _stressLevel,
              energyLevel: _energyLevel,
              sleepHours: _sleepHours,
              timeOfDay: _timeOfDay,
              faceEmotionHint: _faceEmotionHint,
              ambienceType: _ambienceType,
              previousDayMood: _previousDayMood,
              onStressChanged: (v) => _update(() => _stressLevel = v),
              onEnergyChanged: (v) => _update(() => _energyLevel = v),
              onSleepChanged: (v) => _update(() => _sleepHours = v),
              onTimeChanged: (v) => _update(() => _timeOfDay = v),
              onFaceChanged: (v) => _update(() => _faceEmotionHint = v),
              onAmbienceChanged: (v) => _update(() => _ambienceType = v),
              onPreviousMoodChanged: (v) => _update(() => _previousDayMood = v),
            ),
            const SizedBox(height: EmoSpace.xl),
            const SectionHeader(
              title: 'Your reading',
              subtitle: 'Updates live as you write or adjust context.',
            ),
            ReadingCard(
              result: _currentResult,
              isAnalyzing: _isAnalyzing,
              error: _error,
              onRetry: () => _runAnalysis(immediate: true),
              onStartPractice: widget.onNavigateToTool == null
                  ? null
                  : (tool) => widget.onNavigateToTool!(tool.id),
            ),
          ],
        ),
      ),
    );
  }
}
