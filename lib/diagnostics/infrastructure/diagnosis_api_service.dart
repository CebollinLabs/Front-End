import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/diagnosis_repository.dart';
import '../domain/diagnosis_result.dart';

class DiagnosisApiService implements DiagnosisRepository {
  final String baseUrl;

  DiagnosisApiService({this.baseUrl = "http://34.230.19.17:8000"});

  @override
  Future<DiagnosisResult> sendImage(File image) async {
    final uri = Uri.parse("$baseUrl/predict");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DiagnosisResult.fromJson(data);
    } else {
      throw Exception("Error al obtener diagnóstico: ${response.body}");
    }
  }
}
