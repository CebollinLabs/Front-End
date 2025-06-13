import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/diagnostics/presentation/select_plot_page.dart';
import 'package:flutter_frontend_app/diagnostics/domain/plot.dart';
import '../presentation/camera_guide_page.dart';
class PreviewPage extends StatelessWidget {
  final File imageFile;

  const PreviewPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '¿Esta es la imagen que deseas analizar?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(imageFile, fit: BoxFit.contain, width: double.infinity),
              ),
            ),
            const SizedBox(height: 32),
            // Botón Repetir (rojo)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => CameraGuidePage()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Repetir",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
            // Botón Confirmar (verde)
            ElevatedButton(
              onPressed: () {
                // Puedes tener tu lista de parcelas como mock temporal
                final plots = [
                  Plot(id: '1', name: 'Parcela Norte'),
                  Plot(id: '2', name: 'Parcela Sur'),
                  Plot(id: '3', name: 'Parcela Este'),
                  // ...agrega más si quieres
                ];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectPlotPage(
                      imageFile: imageFile,
                      plots: plots,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Confirmar",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
