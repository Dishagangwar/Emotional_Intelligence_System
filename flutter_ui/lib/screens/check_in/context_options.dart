import '../../widgets/ui/inputs.dart';

/// Option lists for the contextual signals the engine reads.
/// `value`s are exactly the strings / numbers the model expects.
abstract final class ContextOptions {
  static const List<OptionItem<String>> timeOfDay = [
    OptionItem(value: 'early_morning', label: 'Early morning', emoji: '🌅'),
    OptionItem(value: 'morning', label: 'Morning', emoji: '☀️'),
    OptionItem(value: 'afternoon', label: 'Afternoon', emoji: '🌤️'),
    OptionItem(value: 'evening', label: 'Evening', emoji: '🌇'),
    OptionItem(value: 'night', label: 'Night', emoji: '🌙'),
  ];

  static const List<OptionItem<String>> faceHint = [
    OptionItem(
      value: 'calm_face',
      label: 'Calm',
      emoji: '😌',
      caption: 'Relaxed, soft expression',
    ),
    OptionItem(
      value: 'happy_face',
      label: 'Happy',
      emoji: '😊',
      caption: 'Smiling or bright',
    ),
    OptionItem(
      value: 'neutral_face',
      label: 'Neutral',
      emoji: '😐',
      caption: 'Nothing in particular',
    ),
    OptionItem(
      value: 'tired_face',
      label: 'Tired',
      emoji: '🥱',
      caption: 'Heavy eyes, low energy',
    ),
    OptionItem(
      value: 'tense_face',
      label: 'Tense',
      emoji: '😣',
      caption: 'Tight jaw or brow',
    ),
    OptionItem(
      value: 'none',
      label: 'Not sure',
      emoji: '🫥',
      caption: "Don't use expression",
    ),
  ];

  static const List<OptionItem<double>> sleep = [
    OptionItem(
      value: 4.0,
      label: '4 hours',
      emoji: '🌘',
      caption: 'Short night',
    ),
    OptionItem(
      value: 5.5,
      label: '5.5 hours',
      emoji: '🌗',
      caption: 'A little under',
    ),
    OptionItem(
      value: 7.0,
      label: '7 hours',
      emoji: '🌖',
      caption: 'About right',
    ),
    OptionItem(
      value: 8.5,
      label: '8.5 hours',
      emoji: '🌕',
      caption: 'Well rested',
    ),
    OptionItem(
      value: 10.0,
      label: '10+ hours',
      emoji: '✨',
      caption: 'Long sleep',
    ),
  ];

  static const List<OptionItem<String>> ambience = [
    OptionItem(value: 'ocean', label: 'Ocean', emoji: '🌊'),
    OptionItem(value: 'forest', label: 'Forest', emoji: '🌲'),
    OptionItem(value: 'rain', label: 'Rain', emoji: '🌧️'),
    OptionItem(value: 'mountain', label: 'Mountain', emoji: '🏔️'),
    OptionItem(value: 'cafe', label: 'Café', emoji: '☕'),
  ];

  static const List<OptionItem<String>> previousMood = [
    OptionItem(value: 'focused', label: 'Focused', emoji: '🎯'),
    OptionItem(value: 'calm', label: 'Calm', emoji: '🍃'),
    OptionItem(value: 'restless', label: 'Restless', emoji: '⚡'),
    OptionItem(value: 'overwhelmed', label: 'Overwhelmed', emoji: '🌊'),
    OptionItem(value: 'mixed', label: 'Mixed', emoji: '🌗'),
    OptionItem(value: 'neutral', label: 'Neutral', emoji: '⚪'),
  ];

  static OptionItem<T> find<T>(
    List<OptionItem<T>> options,
    T value, {
    required OptionItem<T> fallback,
  }) {
    for (final o in options) {
      if (o.value == value) return o;
    }
    return fallback;
  }

  static String sleepLabel(double hours) {
    final s = hours == hours.roundToDouble()
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(1);
    return hours >= 10 ? '${s}h+' : '${s}h';
  }
}
