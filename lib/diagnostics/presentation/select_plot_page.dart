import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/plot.dart';
import '../infrastructure/plot_api_service.dart';
import '../infrastructure/diagnosis_api_service.dart';
import '../domain/diagnosis_result.dart';
import 'result_page.dart';

class SelectPlotPage extends StatefulWidget {
  final File imageFile;
  const SelectPlotPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<SelectPlotPage> createState() => _SelectPlotPageState();
}

class _SelectPlotPageState extends State<SelectPlotPage> {
  Plot? _selectedPlot;
  late Future<List<Plot>> _plotsFuture;
  final _nameController = TextEditingController();
  final _commentsController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _plotsFuture = PlotApiService().fetchPlots();
  }

  Future<void> _showAddPlotDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final borderColor = Colors.green.shade200;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar nueva parcela"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Nombre de la parcela",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor)),
            ),
            autofocus: true,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? "El nombre es obligatorio"
                : " ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await PlotApiService().createPlot(controller.text.trim());
                setState(() {
                  _plotsFuture = PlotApiService().fetchPlots();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parcela creada con éxito')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo crear la parcela')),
                );
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendDiagnosis() async {
    if (_selectedPlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes seleccionar una parcela.")),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await DiagnosisApiService().sendDiagnosisRequest(
        image: widget.imageFile,
        plotId: _selectedPlot!.id,
        name: _nameController.text.trim(),
        comments: _commentsController.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            imageFile: widget.imageFile,
            result: result,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar diagnóstico: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.green.shade200;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Asocia la imagen a una parcela",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                ),
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 120,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Selecciona una parcela",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Plot>>(
              future: _plotsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Error al cargar parcelas'));

                final plots = snapshot.data ?? [];
                return DropdownButtonFormField<Plot>(
                  value: _selectedPlot,
                  items: plots
                      .map((plot) => DropdownMenuItem(
                    value: plot,
                    child: Text(plot.name),
                  ))
                      .toList(),
                  onChanged: (plot) {
                    setState(() {
                      _selectedPlot = plot;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: "Elige una parcela",
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _showAddPlotDialog,
                icon: const Icon(Icons.add),
                label: const Text("Agregar nueva parcela"),
                style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la evaluación (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Comentarios adicionales (opcional)',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const Spacer(),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _sendDiagnosis,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Enviar para diagnóstico",
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
