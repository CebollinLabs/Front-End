import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/diagnostics/presentation/camera_guide_page.dart';
import 'package:flutter_frontend_app/plots/presentation/list_plots_page.dart';
import 'package:flutter_frontend_app/plots/application/plot_service.dart';
import 'package:flutter_frontend_app/plots/infrastructure/plot_api_service.dart';
import 'package:flutter_frontend_app/home/home_page.dart';

void main() {
  final plotService = PlotService(PlotApiService()); // Aquí puedes pasarle otros parámetros si los necesita
  runApp(MyApp(plotService: plotService));
}

class MyApp extends StatelessWidget {
  final PlotService plotService;
  const MyApp({super.key,required this.plotService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnóstico de Plantas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      //home: ListPlotsPage(service: plotService),
      home: HomePage(userName: "Diego", plotService: plotService),

    );
  }
}
