import 'package:flutter/services.dart' show rootBundle;
import '../models/reflection_input.dart';
import '../models/prediction_result.dart';

class DataRepository {
  static List<ReflectionInput> _cachedTestInputs = [];
  static List<PredictionResult> _cachedPredictions = [];

  // Curated instant test samples from test_data.csv for immediate quick testing
  static final List<ReflectionInput> sampleScenarios = [
    const ReflectionInput(
      id: 10001,
      journalText: "Woke up feeling more organized mentally. I was more tired than I thought.",
      ambienceType: "cafe",
      durationMin: 4,
      sleepHours: 8.5,
      energyLevel: 3,
      stressLevel: 1,
      timeOfDay: "night",
      previousDayMood: "mixed",
      faceEmotionHint: "happy_face",
      reflectionQuality: "vague",
    ),
    const ReflectionInput(
      id: 10002,
      journalText: "Started off distracted most of the time. This was better than yesterday.",
      ambienceType: "mountain",
      durationMin: 4,
      sleepHours: 8.5,
      energyLevel: 1,
      stressLevel: 2,
      timeOfDay: "afternoon",
      previousDayMood: "mixed",
      faceEmotionHint: "happy_face",
      reflectionQuality: "clear",
    ),
    const ReflectionInput(
      id: 10004,
      journalText: "After the session I felt able to think straight. My breathing slowed for a moment.",
      ambienceType: "ocean",
      durationMin: 7,
      sleepHours: 7.0,
      energyLevel: 2,
      stressLevel: 3,
      timeOfDay: "morning",
      previousDayMood: "overwhelmed",
      faceEmotionHint: "none",
      reflectionQuality: "clear",
    ),
    const ReflectionInput(
      id: 10009,
      journalText: "For a while I was itchy in my head, but ocean audio was nice.",
      ambienceType: "rain",
      durationMin: 4,
      sleepHours: 8.5,
      energyLevel: 4,
      stressLevel: 4,
      timeOfDay: "evening",
      previousDayMood: "overwhelmed",
      faceEmotionHint: "tense_face",
      reflectionQuality: "conflicted",
    ),
    const ReflectionInput(
      id: 10011,
      journalText: "Started off like everything piled up, but forest sounds worked for a bit...",
      ambienceType: "ocean",
      durationMin: 30,
      sleepHours: 5.0,
      energyLevel: 2,
      stressLevel: 5,
      timeOfDay: "morning",
      previousDayMood: "neutral",
      faceEmotionHint: "calm_face",
      reflectionQuality: "clear",
    ),
    const ReflectionInput(
      id: 10012,
      journalText: "Ok session.",
      ambienceType: "rain",
      durationMin: 20,
      sleepHours: 7.0,
      energyLevel: 2,
      stressLevel: 3,
      timeOfDay: "afternoon",
      previousDayMood: "neutral",
      faceEmotionHint: "calm_face",
      reflectionQuality: "conflicted",
    ),
  ];

  /// Loads full predictions from bundled predictions.csv
  static Future<List<PredictionResult>> loadAllPredictions() async {
    if (_cachedPredictions.isNotEmpty) return _cachedPredictions;

    try {
      final rawData = await rootBundle.loadString('assets/predictions.csv');
      final lines = rawData.split(RegExp(r'\r?\n'));
      if (lines.isEmpty) return [];

      final header = _parseCsvLine(lines[0]);
      final results = <PredictionResult>[];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final cols = _parseCsvLine(line);
        if (cols.length >= header.length) {
          final map = <String, String>{};
          for (int c = 0; c < header.length; c++) {
            map[header[c].trim()] = cols[c].trim();
          }
          results.add(PredictionResult.fromCsvMap(map));
        }
      }

      _cachedPredictions = results;
      return _cachedPredictions;
    } catch (e) {
      // Return default curated items if asset loading fails in test
      return [
        const PredictionResult(
          id: 10001,
          predictedState: "focused",
          predictedIntensity: 3,
          confidence: 0.798,
          uncertainFlag: 0,
          whatToDo: "sound_therapy",
          whenToDo: "tonight",
          supportMessage: "You seem a bit focused. A small step can help improve your state.",
        ),
        const PredictionResult(
          id: 10004,
          predictedState: "focused",
          predictedIntensity: 5,
          confidence: 0.855,
          uncertainFlag: 0,
          whatToDo: "deep_work",
          whenToDo: "now",
          supportMessage: "You seem quite focused. Let's take a moment to reset with a focused activity.",
        ),
        const PredictionResult(
          id: 10009,
          predictedState: "restless",
          predictedIntensity: 4,
          confidence: 0.884,
          uncertainFlag: 0,
          whatToDo: "grounding",
          whenToDo: "within_15_min",
          supportMessage: "You seem quite restless. Let's take a moment to reset with a focused activity.",
        ),
        const PredictionResult(
          id: 10011,
          predictedState: "overwhelmed",
          predictedIntensity: 4,
          confidence: 0.342,
          uncertainFlag: 1,
          whatToDo: "box_breathing",
          whenToDo: "now",
          supportMessage: "You seem quite overwhelmed. Let's take a moment to reset with a focused activity.",
        ),
      ];
    }
  }

  /// Loads test dataset inputs from assets
  static Future<List<ReflectionInput>> loadAllTestInputs() async {
    if (_cachedTestInputs.isNotEmpty) return _cachedTestInputs;

    try {
      final rawData = await rootBundle.loadString('assets/test_data.csv');
      final lines = rawData.split(RegExp(r'\r?\n'));
      if (lines.isEmpty) return sampleScenarios;

      final header = _parseCsvLine(lines[0]);
      final results = <ReflectionInput>[];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final cols = _parseCsvLine(line);
        if (cols.length >= header.length) {
          final map = <String, String>{};
          for (int c = 0; c < header.length; c++) {
            map[header[c].trim()] = cols[c].trim();
          }
          results.add(ReflectionInput.fromCsvMap(map));
        }
      }

      _cachedTestInputs = results.isNotEmpty ? results : sampleScenarios;
      return _cachedTestInputs;
    } catch (e) {
      return sampleScenarios;
    }
  }

  /// Simple and robust CSV line splitter that handles quotes
  static List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}
