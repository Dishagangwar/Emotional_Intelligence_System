import 'prediction_result.dart';
import 'reflection_input.dart';

/// A saved check-in: the user's input plus the engine's result, as stored in
/// the Supabase `check_ins` table.
class CheckInRecord {
  final String id;
  final DateTime createdAt;
  final ReflectionInput input;
  final PredictionResult result;

  const CheckInRecord({
    required this.id,
    required this.createdAt,
    required this.input,
    required this.result,
  });

  /// Row payload for an insert. `id`, `user_id` and `created_at` are filled
  /// in by the database.
  static Map<String, dynamic> toInsertRow(
    ReflectionInput input,
    PredictionResult result,
  ) => {
    'journal_text': input.journalText,
    'ambience_type': input.ambienceType,
    'sleep_hours': input.sleepHours,
    'energy_level': input.energyLevel,
    'stress_level': input.stressLevel,
    'time_of_day': input.timeOfDay,
    'previous_day_mood': input.previousDayMood,
    'face_emotion_hint': input.faceEmotionHint,
    'predicted_state': result.predictedState,
    'predicted_intensity': result.predictedIntensity,
    'confidence': result.confidence,
    'uncertain': result.isUncertain,
    'what_to_do': result.whatToDo,
    'when_to_do': result.whenToDo,
    'support_message': result.supportMessage,
    'state_probabilities': result.stateProbabilities,
  };

  factory CheckInRecord.fromRow(Map<String, dynamic> row) {
    double toDouble(Object? v, double fallback) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? fallback;
    int toInt(Object? v, int fallback) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? fallback;

    final probsRaw = row['state_probabilities'];
    final probs = <String, double>{
      if (probsRaw is Map)
        for (final e in probsRaw.entries) '${e.key}': toDouble(e.value, 0),
    };

    return CheckInRecord(
      id: '${row['id']}',
      createdAt:
          DateTime.tryParse('${row['created_at']}')?.toLocal() ??
          DateTime.now(),
      input: ReflectionInput(
        journalText: '${row['journal_text'] ?? ''}',
        ambienceType: '${row['ambience_type'] ?? 'ocean'}',
        sleepHours: toDouble(row['sleep_hours'], 7),
        energyLevel: toInt(row['energy_level'], 3),
        stressLevel: toInt(row['stress_level'], 3),
        timeOfDay: '${row['time_of_day'] ?? 'afternoon'}',
        previousDayMood: '${row['previous_day_mood'] ?? 'neutral'}',
        faceEmotionHint: '${row['face_emotion_hint'] ?? 'neutral_face'}',
      ),
      result: PredictionResult(
        id: 0,
        predictedState: '${row['predicted_state'] ?? 'neutral'}',
        predictedIntensity: toInt(row['predicted_intensity'], 1),
        confidence: toDouble(row['confidence'], 0),
        uncertainFlag: row['uncertain'] == true ? 1 : 0,
        whatToDo: '${row['what_to_do'] ?? 'rest'}',
        whenToDo: '${row['when_to_do'] ?? 'now'}',
        supportMessage: '${row['support_message'] ?? ''}',
        stateProbabilities: probs,
      ),
    );
  }
}
