import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'plots/application/plot_service.dart';
import 'plots/infrastructure/plot_api_service.dart';
import 'home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final plotService = PlotService(PlotApiService());
  runApp(MyApp(plotService: plotService));
}

class MyApp extends StatelessWidget {
  final PlotService plotService;
  const MyApp({super.key, required this.plotService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnóstico de Plantas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(userName: "Diego", plotService: plotService),
    );
  }
}
