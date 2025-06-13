import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/diagnosis_repository.dart';
import '../domain/diagnosis_result.dart';

class DiagnosisApiService implements DiagnosisRepository {
  final String baseUrl;

  DiagnosisApiService({this.baseUrl = "http://54.146.166.81:8000"});

  @override
  Future<DiagnosisResult> sendImage(File image) async {
    var uri = Uri.parse("$baseUrl/predict");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // PARSEA DIRECTO A DiagnosisResult
      return DiagnosisResult.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al obtener diagnóstico: ${response.body}");
    }
  }
}
