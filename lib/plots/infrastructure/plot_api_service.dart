import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/plot.dart';
import '../domain/plot_repository.dart';

class PlotApiService implements PlotRepository {
  final String baseUrl = "http://192.168.100.47:8000/api/v1/plots/";

  @override
  Future<List<Plot>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    final List data = json.decode(res.body);
    return data.map((e) => Plot.fromJson(e)).toList();
  }

  @override
  Future<void> create(String name) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
  }

  @override
  Future<void> update(String id, String name) async {
    await http.put(
      Uri.parse("$baseUrl$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
  }
}
