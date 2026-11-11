import 'dart:math';
import '../models/reflection_input.dart';
import '../models/prediction_result.dart';

class IntelligenceEngine {
  static final Random _random = Random();

  // Emotion lexicons inspired by training TF-IDF top n-grams
  static final Map<String, List<String>> _emotionKeywords = {
    'focused': [
      'focus', 'concentrate', 'clear', 'clarity', 'task', 'organized', 
      'straight', 'productive', 'deep work', 'continue', 'began', 'steps', 
      'accomplish', 'prioritize', 'plan', 'less chaotic', 'one thing'
    ],
    'calm': [
      'calm', 'peaceful', 'slowed', 'settled', 'grounded', 'relax', 
      'breathe', 'less tense', 'soothing', 'gentle', 'pause', 'quiet', 
      'still', 'relaxed', 'pleasant', 'lighter'
    ],
    'restless': [
      'racing', 'jumping', 'buzz', 'fidgety', 'itchy', 'wandered', 
      'distracted', 'drift', 'restless', 'uneasy', 'fidget', 'scattered', 
      'jumping between', 'low buzz', 'agitated', 'antsy'
    ],
    'overwhelmed': [
      'overwhelmed', 'pressure', 'piled up', 'too much', 'burden', 'heavy', 
      'tense', 'exhausted', 'drowning', 'chaotic', 'hard', 'sitting hard', 
      'crushed', 'cannot keep up', 'anxious', 'stuck', 'stress'
    ],
    'mixed': [
      'mixed', 'part of me', 'conflicted', 'both', 'unsure', 'a little better', 
      'a little off', 'not fully there', 'somewhat', 'torn', 'up and down', 
      'halfway', 'neither'
    ],
    'neutral': [
      'normal', 'ok', 'okay', 'fairly', 'nothing strong', 'shifted much', 
      'idk', 'fine', 'average', 'as usual', 'standard', 'regular'
    ]
  };

  /// Main Inference Method: Computes hybrid state, intensity, and actionable guidance
  static PredictionResult predict(ReflectionInput input) {
    final text = input.journalText.toLowerCase().trim();
    final words = text.split(RegExp(r'\s+'));
    final wordCount = words.where((w) => w.isNotEmpty).length;

    // 1. Initial prior probabilities based on metadata & context
    final Map<String, double> scores = {
      'focused': 1.0,
      'calm': 1.0,
      'restless': 1.0,
      'overwhelmed': 1.0,
      'mixed': 1.0,
      'neutral': 1.0,
    };

    // Stress Influence
    if (input.stressLevel >= 4) {
      scores['overwhelmed'] = scores['overwhelmed']! + 2.5 * (input.stressLevel - 3);
      scores['restless'] = scores['restless']! + 1.8 * (input.stressLevel - 3);
      scores['calm'] = scores['calm']! - 1.5;
    } else if (input.stressLevel <= 2) {
      scores['calm'] = scores['calm']! + 2.5;
      scores['focused'] = scores['focused']! + 1.5;
      scores['overwhelmed'] = scores['overwhelmed']! - 2.0;
    }

    // Energy Influence
    if (input.energyLevel >= 4) {
      scores['focused'] = scores['focused']! + 2.0;
      scores['restless'] = scores['restless']! + 1.2;
    } else if (input.energyLevel <= 2) {
      scores['overwhelmed'] = scores['overwhelmed']! + 1.5;
      scores['neutral'] = scores['neutral']! + 1.0;
    }

    // Sleep Influence
    if (input.sleepHours < 5.5) {
      scores['overwhelmed'] = scores['overwhelmed']! + 1.8;
      scores['restless'] = scores['restless']! + 1.2;
    } else if (input.sleepHours >= 7.5) {
      scores['calm'] = scores['calm']! + 1.8;
      scores['focused'] = scores['focused']! + 1.2;
    }

    // Facial Emotion Hint
    switch (input.faceEmotionHint) {
      case 'happy_face':
        scores['calm'] = scores['calm']! + 1.8;
        scores['focused'] = scores['focused']! + 1.5;
        break;
      case 'calm_face':
        scores['calm'] = scores['calm']! + 2.5;
        scores['focused'] = scores['focused']! + 1.0;
        break;
      case 'tense_face':
        scores['overwhelmed'] = scores['overwhelmed']! + 2.5;
        scores['restless'] = scores['restless']! + 2.0;
        break;
      case 'tired_face':
        scores['overwhelmed'] = scores['overwhelmed']! + 1.5;
        scores['neutral'] = scores['neutral']! + 1.0;
        break;
      case 'neutral_face':
        scores['neutral'] = scores['neutral']! + 2.0;
        break;
    }

    // Previous Day Mood Hint
    if (scores.containsKey(input.previousDayMood)) {
      scores[input.previousDayMood] = scores[input.previousDayMood]! + 1.2;
    }

    // 2. Text Keyword Matching (TF-IDF Analog)
    for (var entry in _emotionKeywords.entries) {
      final emotion = entry.key;
      final keywords = entry.value;
      for (var kw in keywords) {
        if (text.contains(kw)) {
          scores[emotion] = scores[emotion]! + 3.0;
        }
      }
    }

    // Penalize short or ambiguous text
    if (wordCount < 4) {
      scores['neutral'] = scores['neutral']! + 1.5;
      scores['mixed'] = scores['mixed']! + 1.0;
    }

    // Normalize using Softmax to get calibrated probabilities
    final expScores = <String, double>{};
    double sumExp = 0.0;
    for (var entry in scores.entries) {
      final val = entry.value.clamp(-5.0, 15.0);
      final e = exp(val);
      expScores[entry.key] = e;
      sumExp += e;
    }

    final probabilities = <String, double>{};
    String bestState = 'neutral';
    double maxProb = 0.0;

    expScores.forEach((state, expVal) {
      final p = expVal / (sumExp == 0 ? 1.0 : sumExp);
      probabilities[state] = p;
      if (p > maxProb) {
        maxProb = p;
        bestState = state;
      }
    });

    // Handle confidence & uncertainty flag
    final confidence = maxProb;
    final int uncertainFlag = (confidence < 0.60 || wordCount <= 3) ? 1 : 0;

    // 3. Intensity Prediction (1 to 5 scale)
    int predictedIntensity = 3;
    if (bestState == 'overwhelmed') {
      predictedIntensity = input.stressLevel >= 4 ? 5 : 4;
    } else if (bestState == 'restless') {
      predictedIntensity = (input.stressLevel >= 4 || input.energyLevel >= 4) ? 4 : 3;
    } else if (bestState == 'focused') {
      predictedIntensity = input.energyLevel >= 4 ? 4 : 3;
    } else if (bestState == 'calm') {
      predictedIntensity = input.stressLevel <= 2 ? 3 : 2;
    } else if (bestState == 'neutral') {
      predictedIntensity = 1;
    } else {
      predictedIntensity = (input.stressLevel >= 3) ? 3 : 2;
    }

    // 4. Decision Engine (Rule-based exact logic from Model.ipynb)
    final decision = _decide(
      state: bestState,
      intensity: predictedIntensity,
      stress: input.stressLevel,
      energy: input.energyLevel,
      time: input.timeOfDay,
    );

    final whatToDo = decision['action']!;
    final whenToDo = decision['timing']!;

    // 5. Supportive Empathetic Message
    final supportMsg = _generateMessage(bestState, predictedIntensity, whatToDo);

    return PredictionResult(
      id: input.id ?? (_random.nextInt(90000) + 10000),
      predictedState: bestState,
      predictedIntensity: predictedIntensity,
      confidence: confidence,
      uncertainFlag: uncertainFlag,
      whatToDo: whatToDo,
      whenToDo: whenToDo,
      supportMessage: supportMsg,
      stateProbabilities: probabilities,
    );
  }

  /// Rule-based decision layer from Model.ipynb
  static Map<String, String> _decide({
    required String state,
    required int intensity,
    required int stress,
    required int energy,
    required String time,
  }) {
    state = state.toLowerCase();

    // HIGH INTENSITY
    if (intensity >= 4) {
      if (state == 'overwhelmed' || state == 'stressed') {
        return {'action': 'box_breathing', 'timing': 'now'};
      } else if (state == 'restless') {
        return {'action': 'grounding', 'timing': 'within_15_min'};
      } else if (state == 'focused') {
        return {'action': 'deep_work', 'timing': 'now'};
      } else if (state == 'calm') {
        return {'action': 'deep_work', 'timing': 'within_15_min'};
      } else if (state == 'mixed') {
        return {'action': 'journaling', 'timing': 'now'};
      }
    }

    // LOW ENERGY
    if (energy <= 2) {
      return {'action': 'rest', 'timing': 'now'};
    }

    // MODERATE CASES
    if (state == 'neutral') {
      return {'action': 'light_planning', 'timing': 'later_today'};
    }
    if (state == 'restless') {
      return {'action': 'movement', 'timing': 'within_15_min'};
    }
    if (state == 'calm') {
      return {'action': 'deep_work', 'timing': 'later_today'};
    }
    if (state == 'focused') {
      return {'action': 'deep_work', 'timing': 'now'};
    }

    // NIGHT
    if (time == 'night') {
      return {'action': 'sound_therapy', 'timing': 'tonight'};
    }

    return {'action': 'light_planning', 'timing': 'later_today'};
  }

  /// Empathetic human-centered supportive messaging
  static String _generateMessage(String state, int intensity, String action) {
    final readableAction = action.replaceAll('_', ' ');

    final highMsgs = [
      "You seem quite $state. Let's slow down and try $readableAction.",
      "It looks like you're feeling $state. A $readableAction could help you reset.",
      "You're experiencing strong $state feelings. Try $readableAction to regain balance."
    ];

    final mediumMsgs = [
      "You seem a bit $state. A small step like $readableAction might help.",
      "You're slightly $state. Consider trying $readableAction.",
      "A bit of $state is noticeable. $readableAction could improve your state."
    ];

    final lowMsgs = [
      "You seem stable. You can continue your current flow.",
      "You're doing okay. Keep going!",
      "Everything looks balanced. Maintain your current rhythm."
    ];

    if (intensity >= 4) {
      return highMsgs[_random.nextInt(highMsgs.length)];
    } else if (intensity >= 3) {
      return mediumMsgs[_random.nextInt(mediumMsgs.length)];
    } else {
      return lowMsgs[_random.nextInt(lowMsgs.length)];
    }
  }
}
