// domain/models.dart
class Prediction {
  final String className;
  final double confidence;
  const Prediction({required this.className, required this.confidence});
}

class Plot {
  final String id;
  final String name;
  const Plot({required this.id, required this.name});
  String get displayName => name.isEmpty ? 'Plot sin nombre' : name;
}

class DiagnosisRequest {
  final String id;
  final String status;           // COMPLETED | PENDING | FAILED | PROCESSING
  final DateTime submittedAt;    // UTC
  final String diagnosisResult;  // class_name top
  final List<Prediction> predictions;
  final String? imageUrl;
  final Plot plot;

  const DiagnosisRequest({
    required this.id,
    required this.status,
    required this.submittedAt,
    required this.diagnosisResult,
    required this.predictions,
    required this.imageUrl,
    required this.plot,
  });

  Prediction get topPrediction =>
      (predictions..sort((a,b)=>b.confidence.compareTo(a.confidence))).first;
}
