// result_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../application/send_image_usecase.dart';
import '../domain/diagnosis_result.dart';
import '../infrastructure/diagnosis_api_service.dart';
import '../presentation/camera_guide_page.dart';
class ResultPage extends StatefulWidget {
  final File imageFile;

  const ResultPage({super.key, required this.imageFile});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<DiagnosisResult> _resultFuture;

  @override
  void initState() {
    super.initState();
    final repository = DiagnosisApiService();
    final usecase = SendImageUseCase(repository);
    _resultFuture = usecase(widget.imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0, // <-- Esto es clave para Flutter 3.10 o superior
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DiagnosisResult>(
          future: _resultFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final result = snapshot.data!;
            final predictions = result.predictions;
            predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
            final topPrediction = predictions.first;

            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultado de diagnóstico',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(  // Centra la imagen, puedes ajustar si prefieres alineado izq.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(widget.imageFile, height: 200),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Diagnóstico: ${topPrediction.label}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Confianza: ${(topPrediction.confidence * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final p = predictions[index];
                        return ListTile(
                          title: Text(p.label),
                          trailing: Text('${(p.confidence * 100).toStringAsFixed(2)}%'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => CameraGuidePage()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Volver al inicio"),
                  ),
                ],
              ),
            );
          },
        ),

    );
  }
}
