import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'plots/application/plot_service.dart';
import 'plots/infrastructure/plot_api_service.dart';
import 'home/home_page.dart';
import 'services/auth_service.dart';
import 'auth/presentation/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase antes de arrancar la app
  await Firebase.initializeApp();

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
      home: StreamBuilder(
        stream: AuthService.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return LoginPage();
          }
          final displayName = user.displayName ?? user.email ?? 'Usuario';
          return HomePage(userName: displayName, plotService: plotService);
        },
      ),
    );
  }
}
