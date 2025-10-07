import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TreatmentApiService {
  final String baseUrl;

  TreatmentApiService({String? baseUrl})
      : baseUrl = (baseUrl ?? dotenv.env['TREATMENT_API_URL'] ?? '').trim() {
    if (this.baseUrl.isEmpty) {
      throw StateError(
        'TREATMENT_API_URL no está definido. Configúralo en .env o pásalo por constructor/--dart-define.',
      );
    }
  }

  Future<Map<String, dynamic>> getTreatmentPlan([String? diagnosisRequestId]) async {
    // Mantengo tu fallback de ID si no te pasan uno:
    final idToUse = diagnosisRequestId ?? '2c7e61cd-615f-4b5e-9825-de11928b4259';

    final uri = Uri.parse('$baseUrl/api/v1/treatment-plans/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'diagnosis_request_id': idToUse}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener tratamiento: ${response.body}');
    }
  }
}
