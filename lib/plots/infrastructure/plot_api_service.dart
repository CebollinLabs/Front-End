import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/auth_service.dart';
import '../domain/plot.dart';
import '../domain/plot_repository.dart';

class PlotApiService implements PlotRepository {
  final String baseUrl;

  PlotApiService() : baseUrl = "${dotenv.env['PLOTS_API_URL']}/api/v1/plots/";

  @override
  Future<List<Plot>> getAll() async {
    final token = await AuthService.instance.getIdToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.get(Uri.parse(baseUrl), headers: headers);
    final List data = json.decode(res.body);
    return data.map((e) => Plot.fromJson(e)).toList();
  }

  @override
  Future<void> create(String name) async {
    final token = await AuthService.instance.getIdToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }

  @override
  Future<void> update(String id, String name) async {
    final token = await AuthService.instance.getIdToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    await http.put(
      Uri.parse("$baseUrl$id"),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }


}
