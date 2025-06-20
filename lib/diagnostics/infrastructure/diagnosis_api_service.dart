import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/diagnosis_repository.dart';
import '../domain/diagnosis_result.dart';

class DiagnosisApiService implements DiagnosisRepository {
  final String baseUrl;

  DiagnosisApiService({this.baseUrl = "http://192.168.100.47:8000"});

  @override
  Future<DiagnosisResult> sendDiagnosisRequest({
    required File image,
    required String plotId,
    String name = '',
    String comments = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/diagnosis-requests/');
    final request = http.MultipartRequest('POST', uri);

    print("image: ${image.path}");
    print("plot_id: $plotId");
    print("name: $name");
    print("comments: $comments");

    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['plot_id'] = plotId;
    request.fields['name'] = name;
    request.fields['comments'] = comments;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return DiagnosisResult.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al enviar diagnóstico: ${response.body}");
    }
  }

}
