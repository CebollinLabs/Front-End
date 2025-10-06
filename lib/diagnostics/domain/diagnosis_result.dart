class DiagnosisPrediction {
  final String label;
  final double confidence;

  DiagnosisPrediction({
    required this.label,
    required this.confidence,
  });

  factory DiagnosisPrediction.fromJson(Map<String, dynamic> json) {
    return DiagnosisPrediction(
      label: json['class'],
      confidence: double.parse(json['confidence'].toString()),
    );
  }
}

class DiagnosisResult {
  final String diagnosisRequestId; // ✅ Agregado
  final String filename;
  final List<DiagnosisPrediction> predictions;

  DiagnosisResult({
    required this.diagnosisRequestId,
    required this.filename,
    required this.predictions,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      diagnosisRequestId: json['diagnosis_request_id'] ?? "unknown-id",
      filename: json['filename'] ?? "unknown",
      predictions: (json['predictions'] as List? ?? [])
          .map((item) => DiagnosisPrediction.fromJson(item))
          .toList(),
    );
  }
}
