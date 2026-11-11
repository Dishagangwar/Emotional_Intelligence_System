class PredictionResult {
  final int id;
  final String predictedState;
  final int predictedIntensity;
  final double confidence;
  final int uncertainFlag;
  final String whatToDo;
  final String whenToDo;
  final String supportMessage;
  final Map<String, double> stateProbabilities;

  const PredictionResult({
    required this.id,
    required this.predictedState,
    required this.predictedIntensity,
    required this.confidence,
    required this.uncertainFlag,
    required this.whatToDo,
    required this.whenToDo,
    required this.supportMessage,
    this.stateProbabilities = const {},
  });

  bool get isUncertain => uncertainFlag == 1 || confidence < 0.60;

  factory PredictionResult.fromCsvMap(Map<String, String> map) {
    return PredictionResult(
      id: int.tryParse(map['id'] ?? '') ?? 0,
      predictedState: map['predicted_state'] ?? 'neutral',
      predictedIntensity: int.tryParse(map['predicted_intensity'] ?? '1') ?? 1,
      confidence: double.tryParse(map['confidence'] ?? '0.5') ?? 0.5,
      uncertainFlag: int.tryParse(map['uncertain_flag'] ?? '0') ?? 0,
      whatToDo: map['what_to_do'] ?? 'rest',
      whenToDo: map['when_to_do'] ?? 'now',
      supportMessage: map['support_message'] ?? '',
      stateProbabilities: {},
    );
  }
}
