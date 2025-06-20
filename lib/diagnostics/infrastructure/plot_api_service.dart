import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/plot.dart';

class PlotApiService {
  final String baseUrl = "http://192.168.100.47:8000/api/v1/plots/";

  Future<List<Plot>> fetchPlots() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Plot.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener parcelas");
    }
  }
  Future<void> createPlot(String name) async {
    final response = await http.post(Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("No se pudo crear la parcela");
    }
  }

}
