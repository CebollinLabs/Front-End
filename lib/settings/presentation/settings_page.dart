import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estados para los switches
  bool wifiOnly = true;
  bool notificationsEnabled = true;
  bool offlineSync = false;
  String syncStatus = "Sincronizado";
  String selectedLanguage = "Español";
  Color bgColor = Colors.white;

  final languages = ["Español", "English"];

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: green,
        elevation: 0,
        title: const Text("Configuración", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        children: [
          const SizedBox(height: 4),
          Text("Preferencias de Sincronización",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: green, fontSize: 18)),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Sincronizar solo por WiFi"),
                  subtitle: const Text("Evita consumo de datos móviles"),
                  value: wifiOnly,
                  onChanged: (v) => setState(() => wifiOnly = v),
                  activeThumbColor: green,
                ),
                SwitchListTile(
                  title: const Text("Sincronización offline"),
                  subtitle: const Text("Permite uso sin conexión y sincroniza al estar online"),
                  value: offlineSync,
                  onChanged: (v) => setState(() => offlineSync = v),
                  activeThumbColor: green,
                ),
                ListTile(
                  title: const Text("Estado de sincronización"),
                  subtitle: Text(syncStatus, style: const TextStyle(fontWeight: FontWeight.w500)),
                  leading: Icon(Icons.sync, color: green),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Sincronizar ahora"),
                    onPressed: () {
                      setState(() => syncStatus = "Sincronizado (ahora)");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sincronización realizada')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text("Notificaciones y Preferencias",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: green, fontSize: 18)),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Recibir notificaciones"),
                  subtitle: const Text("Incluye alertas de diagnóstico y novedades"),
                  value: notificationsEnabled,
                  onChanged: (v) => setState(() => notificationsEnabled = v),
                  activeThumbColor: green,
                ),
                ListTile(
                  title: const Text("Idioma de la aplicación"),
                  trailing: DropdownButton<String>(
                    value: selectedLanguage,
                    borderRadius: BorderRadius.circular(10),
                    items: languages
                        .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    ))
                        .toList(),
                    onChanged: (lang) {
                      if (lang != null) setState(() => selectedLanguage = lang);
                    },
                  ),
                  leading: Icon(Icons.language, color: green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text("Color de fondo",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: green, fontSize: 18)),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              title: const Text("Cambiar color de fondo"),
              subtitle: Text("Personaliza tu experiencia visual"),
              leading: Icon(Icons.format_paint, color: green),
              trailing: DropdownButton<Color>(
                value: bgColor,
                borderRadius: BorderRadius.circular(10),
                items: [
                  DropdownMenuItem(
                    value: Colors.white,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 18, shadows: [
                          Shadow(blurRadius: 1, color: Colors.black26)
                        ]),
                        const SizedBox(width: 8),
                        const Text("Claro"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: const Color(0xFF1E1E1E),
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: const Color(0xFF1E1E1E), size: 18),
                        const SizedBox(width: 8),
                        const Text("Oscuro"),
                      ],
                    ),
                  ),
                  // Puedes agregar más colores aquí
                ],
                onChanged: (color) {
                  if (color != null) setState(() => bgColor = color);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
