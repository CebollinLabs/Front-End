import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/diagnostics/presentation/camera_guide_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnóstico de Plantas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CameraGuidePage(),
    );
  }
}
