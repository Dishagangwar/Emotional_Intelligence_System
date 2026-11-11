import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emotional_ui/main.dart';
import 'package:emotional_ui/models/check_in_record.dart';
import 'package:emotional_ui/models/reflection_input.dart';
import 'package:emotional_ui/services/backend.dart';
import 'package:emotional_ui/services/intelligence_engine.dart';

void main() {
  test('check-in row round-trips input and engine result', () {
    const input = ReflectionInput(
      journalText: 'Everything piled up and I feel the pressure.',
      ambienceType: 'rain',
      sleepHours: 5.5,
      energyLevel: 2,
      stressLevel: 5,
      timeOfDay: 'evening',
      previousDayMood: 'overwhelmed',
      faceEmotionHint: 'tense_face',
    );
    final result = IntelligenceEngine.predict(input);

    final row = CheckInRecord.toInsertRow(input, result)
      ..['id'] = 'abc'
      ..['created_at'] = '2026-11-11T10:00:00Z';
    final record = CheckInRecord.fromRow(row);

    expect(record.id, 'abc');
    expect(record.input.journalText, input.journalText);
    expect(record.input.sleepHours, 5.5);
    expect(record.input.stressLevel, 5);
    expect(record.input.previousDayMood, 'overwhelmed');
    expect(record.result.predictedState, result.predictedState);
    expect(record.result.predictedIntensity, result.predictedIntensity);
    expect(record.result.confidence, result.confidence);
    expect(record.result.whatToDo, result.whatToDo);
    expect(record.result.isUncertain, result.isUncertain);
    expect(
      record.result.stateProbabilities.keys,
      containsAll(result.stateProbabilities.keys),
    );
  });

  test('row parsing tolerates numeric strings and missing fields', () {
    final record = CheckInRecord.fromRow({
      'id': 1,
      'created_at': 'not-a-date',
      'sleep_hours': '7.5',
      'stress_level': '4',
      'confidence': 0.42,
      'uncertain': true,
    });
    expect(record.input.sleepHours, 7.5);
    expect(record.input.stressLevel, 4);
    expect(record.result.isUncertain, isTrue);
    expect(record.result.stateProbabilities, isEmpty);
  });

  testWidgets('without a Supabase key the app runs offline with no cloud UI', (
    tester,
  ) async {
    expect(Backend.isAvailable, isFalse);
    await tester.pumpWidget(const EmotionalIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('How are you, really?'), findsOneWidget);
    expect(find.text('Save to history'), findsNothing);
    expect(find.bySemanticsLabel('Sign in'), findsNothing);
    expect(find.bySemanticsLabel('Cloud sync is off'), findsOneWidget);

    // The header button explains why cloud features are missing.
    await tester.tap(find.bySemanticsLabel('Cloud sync is off'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Cloud sync is off'), findsOneWidget);
    expect(find.textContaining('without a Supabase key'), findsOneWidget);
    Navigator.of(tester.element(find.text('Cloud sync is off'))).pop();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Insights'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Model insights'), findsOneWidget);
    expect(find.text('My history'), findsNothing);
  });
}
