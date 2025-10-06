import 'dart:convert';
import 'package:http/http.dart' as http;

class TreatmentApiService {
  final String baseUrl;

  TreatmentApiService({this.baseUrl = "http://192.168.100.47:8000"});

  Future<Map<String, dynamic>> getTreatmentPlan([String? diagnosisRequestId]) async {
    // 👇 Usar el ID que pase el método o por defecto este fijo
    final idToUse = diagnosisRequestId ?? "2c7e61cd-615f-4b5e-9825-de11928b4259";

    final uri = Uri.parse("$baseUrl/api/v1/treatment-plans/");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"diagnosis_request_id": idToUse}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al obtener tratamiento: ${response.body}");
    }
  }
}
