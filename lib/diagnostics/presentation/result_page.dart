import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/diagnosis_result.dart';
import '../presentation/camera_guide_page.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;
  final DiagnosisResult result;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final predictions = result.predictions;
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    final topPrediction = predictions.first;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(imageFile, height: 200),
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
      ),
    );
  }
}
