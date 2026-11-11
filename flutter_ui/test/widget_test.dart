import 'package:flutter_test/flutter_test.dart';
import 'package:emotional_ui/main.dart';
import 'package:emotional_ui/models/reflection_input.dart';
import 'package:emotional_ui/services/intelligence_engine.dart';

void main() {
  testWidgets('Emostate app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmotionalIntelligenceApp());
    // Pump one frame with duration to let initial build settle without waiting infinitely on looping animations
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Emostate'), findsOneWidget);
  });

  test(
    'IntelligenceEngine predicts high stress as overwhelmed or restless',
    () {
      const input = ReflectionInput(
        journalText:
            "I feel like everything is piled up and I have too much pressure.",
        stressLevel: 5,
        energyLevel: 2,
      );
      final result = IntelligenceEngine.predict(input);
      expect(result.predictedIntensity, greaterThanOrEqualTo(4));
      expect(result.whatToDo, equals('box_breathing'));
    },
  );

  test('IntelligenceEngine predicts focus and recommends deep work', () {
    const input = ReflectionInput(
      journalText: "Clear clarity and ready to concentrate on my tasks.",
      stressLevel: 2,
      energyLevel: 4,
    );
    final result = IntelligenceEngine.predict(input);
    expect(result.predictedState, equals('focused'));
    expect(result.whatToDo, equals('deep_work'));
  });
}
