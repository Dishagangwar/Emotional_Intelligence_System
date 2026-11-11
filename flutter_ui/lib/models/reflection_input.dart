class ReflectionInput {
  final int? id;
  final String journalText;
  final String ambienceType;
  final double durationMin;
  final double sleepHours;
  final int energyLevel;
  final int stressLevel;
  final String timeOfDay;
  final String previousDayMood;
  final String faceEmotionHint;
  final String reflectionQuality;

  const ReflectionInput({
    this.id,
    required this.journalText,
    this.ambienceType = 'ocean',
    this.durationMin = 15.0,
    this.sleepHours = 7.0,
    this.energyLevel = 3,
    this.stressLevel = 3,
    this.timeOfDay = 'afternoon',
    this.previousDayMood = 'neutral',
    this.faceEmotionHint = 'neutral_face',
    this.reflectionQuality = 'clear',
  });

  ReflectionInput copyWith({
    int? id,
    String? journalText,
    String? ambienceType,
    double? durationMin,
    double? sleepHours,
    int? energyLevel,
    int? stressLevel,
    String? timeOfDay,
    String? previousDayMood,
    String? faceEmotionHint,
    String? reflectionQuality,
  }) {
    return ReflectionInput(
      id: id ?? this.id,
      journalText: journalText ?? this.journalText,
      ambienceType: ambienceType ?? this.ambienceType,
      durationMin: durationMin ?? this.durationMin,
      sleepHours: sleepHours ?? this.sleepHours,
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      previousDayMood: previousDayMood ?? this.previousDayMood,
      faceEmotionHint: faceEmotionHint ?? this.faceEmotionHint,
      reflectionQuality: reflectionQuality ?? this.reflectionQuality,
    );
  }

  factory ReflectionInput.fromCsvMap(Map<String, String> map) {
    return ReflectionInput(
      id: int.tryParse(map['id'] ?? '') ?? 0,
      journalText: map['journal_text'] ?? '',
      ambienceType: map['ambience_type'] ?? 'ocean',
      durationMin: double.tryParse(map['duration_min'] ?? '15') ?? 15.0,
      sleepHours: double.tryParse(map['sleep_hours'] ?? '7') ?? 7.0,
      energyLevel: int.tryParse(map['energy_level'] ?? '3') ?? 3,
      stressLevel: int.tryParse(map['stress_level'] ?? '3') ?? 3,
      timeOfDay: map['time_of_day'] ?? 'morning',
      previousDayMood: map['previous_day_mood'] ?? 'neutral',
      faceEmotionHint: map['face_emotion_hint'] ?? 'neutral_face',
      reflectionQuality: map['reflection_quality'] ?? 'clear',
    );
  }
}
