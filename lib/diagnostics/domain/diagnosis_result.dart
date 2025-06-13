// diagnosis_result.dart
class DiagnosisPrediction {
  final String label;        // Debe ser label, NO clase
  final double confidence;   // Debe ser confidence, NO confianza

  DiagnosisPrediction({
    required this.label,
    required this.confidence,
  });

  factory DiagnosisPrediction.fromJson(Map<String, dynamic> json) {
    return DiagnosisPrediction(
      label: json['class'],  // el API responde con "class"
      confidence: double.parse(json['confidence']),
    );
  }
}

class DiagnosisResult {
  final String filename;
  final List<DiagnosisPrediction> predictions;

  DiagnosisResult({
    required this.filename,
    required this.predictions,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      filename: json['filename'],
      predictions: (json['predictions'] as List)
          .map((item) => DiagnosisPrediction.fromJson(item))
          .toList(),
    );
  }
}
