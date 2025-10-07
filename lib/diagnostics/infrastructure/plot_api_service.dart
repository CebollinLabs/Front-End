import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/plot.dart';

/// Servicio de API para gestionar parcelas (Plots) sin IPs hardcodeadas.
/// Lee la URL base desde:
/// - Constructor (prioridad), o
/// - Variable de entorno PLOTS_API_URL (dotenv o --dart-define)
/// Si no existe, lanza un error en tiempo de arranque.
class PlotApiService {
  final String baseUrl;
  final http.Client _client;

  PlotApiService({String? baseUrl, http.Client? client})
      : baseUrl = _normalize(baseUrl ?? (dotenv.env['PLOTS_API_URL'] ?? '')),
        _client = client ?? http.Client() {
    if (this.baseUrl.isEmpty) {
      throw StateError(
        'PLOTS_API_URL no está definido. Configúralo en .env o pásalo por --dart-define, '
        'o inyecta baseUrl en el constructor.',
      );
    }
  }

  /// Normaliza la URL base eliminando espacios y el slash final.
  static String _normalize(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  /// Construye el endpoint de plots de forma robusta.
  Uri _plotsEndpoint() => Uri.parse(baseUrl).resolve('/api/v1/plots/');

  /// Lista de parcelas.
  Future<List<Plot>> fetchPlots() async {
    final uri = _plotsEndpoint();
    final resp = await _client.get(uri).timeout(const Duration(seconds: 20));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Plot.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al obtener parcelas: [${resp.statusCode}] ${resp.body}');
  }

  /// Crea una parcela por nombre.
  Future<void> createPlot(String name) async {
    final uri = _plotsEndpoint();
    final resp = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name}),
        )
        .timeout(const Duration(seconds: 20));

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('No se pudo crear la parcela: [${resp.statusCode}] ${resp.body}');
    }
  }

  void close() => _client.close();
}
