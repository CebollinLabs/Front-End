import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/diagnostics/presentation/camera_guide_page.dart';
import 'package:flutter_frontend_app/plots/presentation/list_plots_page.dart';
import 'package:flutter_frontend_app/plots/application/plot_service.dart';
import 'package:flutter_frontend_app/help/presentation/help_page.dart';
import 'package:flutter_frontend_app/help/presentation/about_page.dart';

class HomePage extends StatelessWidget {
  final String userName;
  final PlotService plotService; // <--- NUEVO

  const HomePage({Key? key, required this.userName, required this.plotService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Ayuda',
            icon: const Icon(Icons.help_outline),
            color: green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpPage()),
              );
            },
          ),

          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            color: green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings),
            color: green,
            onPressed: () {
              // TODO: Navegar a configuración
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "¡Hola, $userName!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Bienvenido a tu app de agricultura inteligente.",
              style: TextStyle(fontSize: 17, color: Colors.grey[700]),
            ),
            const SizedBox(height: 22),

            // Botón ver perfil
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: Colors.green.shade50,
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                radius: 24,
                child: Icon(Icons.person, size: 30, color: green),
              ),
              title: const Text(
                "Ver perfil",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                // TODO: Navegar a perfil
              },
            ),
            const SizedBox(height: 22),

            // Cards funciones principales
            Expanded(
              child: ListView(
                children: [
                  _MainFunctionCard(
                    icon: Icons.biotech_rounded,
                    color: Colors.green.shade700,
                    title: 'Diagnóstico de cultivo',
                    subtitle: 'Analiza enfermedades y plagas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraGuidePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _MainFunctionCard(
                    icon: Icons.grass_rounded,
                    color: Colors.green.shade400,
                    title: 'Cosechas / Parcelas',
                    subtitle: 'Gestiona tus lotes de siembra',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListPlotsPage(service: plotService),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _MainFunctionCard(
                    icon: Icons.history_edu_rounded,
                    color: Colors.amber.shade700,
                    title: 'Historial de diagnósticos',
                    subtitle: 'Consulta resultados pasados',
                    onTap: () {
                      // TODO: Navegar a historial
                    },
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

class _MainFunctionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MainFunctionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25), width: 1.1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 36),
                radius: 32,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
