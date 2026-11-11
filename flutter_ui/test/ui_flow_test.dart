import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emotional_ui/main.dart';
import 'package:emotional_ui/screens/insights_screen.dart';
import 'package:emotional_ui/models/reflection_input.dart';
import 'package:emotional_ui/services/intelligence_engine.dart';
import 'package:emotional_ui/theme/emotion_style.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  Size size = const Size(375, 812),
  Brightness brightness = Brightness.dark,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  await tester.pumpWidget(const EmotionalIntelligenceApp());
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _settle(WidgetTester tester) async {
  // The ambient backdrop animates forever, so pump fixed frames instead of pumpAndSettle.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final brightness in Brightness.values) {
    for (final size in const [
      Size(320, 640),
      Size(375, 812),
      Size(820, 1180),
    ]) {
      testWidgets(
        'all tabs render without overflow at ${size.width.toInt()}w ${brightness.name}',
        (tester) async {
          await _pumpApp(tester, size: size, brightness: brightness);
          expect(find.text('How are you, really?'), findsOneWidget);

          await tester.tap(find.text('Practice'));
          await _settle(tester);
          expect(find.text('Reset your state'), findsOneWidget);

          await tester.tap(find.text('Insights'));
          await _settle(tester);
          expect(find.text('Model insights'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('reading shows the live engine result for the initial entry', (
    tester,
  ) async {
    await _pumpApp(tester);
    final expected = IntelligenceEngine.predict(
      const ReflectionInput(
        journalText: "The ocean ambience helped me stop drifting and concentrate on my next steps. My to-do list feels less chaotic.",
        ambienceType: 'ocean',
        sleepHours: 7.0,
        energyLevel: 3,
        stressLevel: 3,
        timeOfDay: 'afternoon',
        faceEmotionHint: 'calm_face',
        previousDayMood: 'neutral',
      ),
    );
    final label = EmotionStyle.of(expected.predictedState).label;
    // State appears in the reading headline and the header pill.
    expect(find.text(label), findsWidgets);
    expect(find.text('${(expected.confidence * 100).round()}%'), findsWidgets);
  });

  testWidgets('typing updates the reading after the debounce', (tester) async {
    await _pumpApp(tester);
    await tester.enterText(
      find.byType(TextField).first,
      'Everything piled up, too much pressure, I feel overwhelmed and exhausted.',
    );
    await tester.pump();
    expect(find.text('Reading…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await _settle(tester);
    expect(find.text('Reading…'), findsNothing);
    expect(find.text('Overwhelmed'), findsWidgets);
  });

  testWidgets('breakdown shows all six state probabilities', (tester) async {
    await _pumpApp(tester);
    final heading = find.text('Signal breakdown');
    await tester.ensureVisible(heading);
    await _settle(tester);
    for (final s in EmotionStyle.all) {
      expect(find.text(s.label), findsWidgets);
    }
  });

  testWidgets('primary CTA opens the matching practice', (tester) async {
    await _pumpApp(tester);
    final cta = find.textContaining('Start ');
    await tester.ensureVisible(cta.first);
    await tester.tap(cta.first);
    await _settle(tester);
    expect(find.text('Reset your state'), findsOneWidget);
  });

  testWidgets('context sheet changes a value and the reading', (tester) async {
    await _pumpApp(tester);
    final tile = find.text('Expression');
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await _settle(tester);
    expect(find.text('How does your face feel?'), findsOneWidget);
    await tester.tap(find.text('Tense'));
    await _settle(tester);
    expect(find.text('How does your face feel?'), findsNothing);
    expect(find.text('Tense'), findsOneWidget);
  });

  testWidgets('example sheet loads a dataset scenario', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Try an example'));
    await _settle(tester);
    await tester.tap(find.textContaining('Woke up feeling more organized'));
    await _settle(tester);
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(
      field.controller!.text,
      startsWith('Woke up feeling more organized'),
    );
  });

  testWidgets('insights filters narrow and clear the list', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Insights'));
    await _settle(tester);
    final scrollable = find
        .descendant(
          of: find.byType(InsightsScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Browse entries'),
      300,
      scrollable: scrollable,
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(InsightsScreen),
        matching: find.byType(TextField),
      ),
      'zzzz-no-match',
    );
    await _settle(tester);
    await tester.scrollUntilVisible(
      find.text('No entries match'),
      200,
      scrollable: scrollable,
    );
    expect(find.text('0 entries'), findsOneWidget);
    await tester.tap(find.text('Clear filters').last);
    await _settle(tester);
    expect(find.text('No entries match'), findsNothing);
  });

  testWidgets('breathing exercise starts and pauses', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Practice'));
    await _settle(tester);
    await tester.ensureVisible(find.text('Begin'));
    await _settle(tester);
    await tester.tap(find.text('Begin'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Breathe in'), findsOneWidget);
    await tester.ensureVisible(find.text('Pause'));
    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Resume'), findsOneWidget);
  });
}
