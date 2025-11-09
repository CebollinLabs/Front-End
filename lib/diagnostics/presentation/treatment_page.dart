import 'package:flutter/material.dart';
import '../infrastructure/treatment_api_service.dart';

class TreatmentPage extends StatefulWidget {
  const TreatmentPage({super.key});

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  Map<String, dynamic>? treatmentPlan;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTreatment();
  }

  Future<void> _fetchTreatment() async {
    try {
      final service = TreatmentApiService();
      final data = await service.getTreatmentPlan(); // 👈 sin pasar ID
      setState(() {
        treatmentPlan = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Widget _buildTreatmentCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plan de tratamiento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
          child: Text(
            "Error: $error",
            style: const TextStyle(color: Colors.red),
          ),
        )
            : treatmentPlan == null
            ? const Center(
          child: Text("No se encontró un plan de tratamiento"),
        )
            : ListView(
          children: [
            const Text(
              "Tratamiento recomendado",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            ...treatmentPlan!.entries.map((entry) {
              return _buildTreatmentCard(
                entry.key,
                entry.value.toString(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
