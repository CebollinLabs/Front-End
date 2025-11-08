// infrastructure/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/models.dart';

class DiagnosisApi {
  /// Mismo mecanismo que DiagnosisApiService: usa DIAGNOSIS_API_URL o permite override.
  final String baseUrl;

  DiagnosisApi({String? baseUrl})
      : baseUrl = baseUrl ?? (dotenv.env['PLOTS_API_URL'] ?? '') {
    if (this.baseUrl.isEmpty) {
      throw StateError(
        'PLOTS_API_URL no está definido en el entorno (.env o --dart-define).',
      );
    }
  }

  Future<List<DiagnosisRequest>> fetchAll() async {
    final uri = Uri.parse(_join(baseUrl, '/api/v1/diagnosis-requests/'));
    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 45)); // ⬅️ más tiempo de espera


    if (res.statusCode != 200) return [];

    final raw = jsonDecode(res.body);
    final list = (raw is List) ? raw : [raw];

    return list.map<DiagnosisRequest>((j) {
      final preds = ((j['predictions'] as List?) ?? [])
          .map((p) => Prediction(
                className: (p['class_name'] ?? '').toString(),
                confidence: ((p['confidence'] ?? 0) as num).toDouble(),
              ))
          .toList();

      final plotJson = (j['plot'] as Map?) ?? {};
      return DiagnosisRequest(
        id: (j['id'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        submittedAt:
            DateTime.parse((j['submitted_at'] ?? '').toString()).toUtc(),
        diagnosisResult: (j['diagnosis_result'] ?? '').toString(),
        predictions: preds,
        imageUrl: (j['image_url'] as String?),
        plot: Plot(
          id: (plotJson['id'] ?? '').toString(),
          name: (plotJson['name'] ?? '').toString(),
        ),
      );
    }).toList();
  }

  /// Une base + path evitando // o faltas de '/'
  static String _join(String base, String path) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }
}
