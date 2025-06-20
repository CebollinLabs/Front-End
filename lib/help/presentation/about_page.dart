import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: green,
        elevation: 0,
        title: const Text("Acerca de", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.eco, color: green, size: 34),
                const SizedBox(width: 10),
                Text(
                  "Cebollin App",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Versión 1.0.0\n\nDesarrollado por CebollinLabs.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(
              "Esta aplicación utiliza inteligencia artificial y tecnología de datos para facilitar el diagnóstico de enfermedades y plagas en cultivos agrícolas, optimizando la gestión de parcelas y mejorando la productividad de los agricultores.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            const Divider(height: 24),
            const Text(
              "Contacto:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "soporte@cebollinlabs.com\n+51 900 000 000",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                // TODO: Abrir URL de política de privacidad
              },
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: green, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    "Política de privacidad",
                    style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
