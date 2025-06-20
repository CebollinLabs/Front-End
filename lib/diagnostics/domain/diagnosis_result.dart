class DiagnosisPrediction {
  final String label;
  final double confidence;

  DiagnosisPrediction({
    required this.label,
    required this.confidence,
  });

  factory DiagnosisPrediction.fromJson(Map<String, dynamic> json) {
    return DiagnosisPrediction(
      label: (json['class_name'] ?? json['class'] ?? json['label'] ?? "").toString(),
      confidence: double.tryParse(json['confidence']?.toString() ?? "0") ?? 0.0,
    );
  }
}

class DiagnosisResult {
  final String filename;
  final List<DiagnosisPrediction> predictions;
  final String name;
  final String comments;

  DiagnosisResult({
    required this.filename,
    required this.predictions,
    required this.name,
    required this.comments,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      filename: json['filename'] ?? "",
      predictions: (json['predictions'] as List)
          .map((item) => DiagnosisPrediction.fromJson(item))
          .toList(),
      name: json['name'] ?? "",
      comments: json['comments'] ?? "",
    );
  }
}

