import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/diagnostics/domain/plot.dart';
import 'package:flutter_frontend_app/diagnostics/presentation/result_page.dart';



class SelectPlotPage extends StatefulWidget {
  final File imageFile;
  final List<Plot> plots;

  const SelectPlotPage({Key? key, required this.imageFile, required this.plots}) : super(key: key);

  @override
  State<SelectPlotPage> createState() => _SelectPlotPageState();
}

class _SelectPlotPageState extends State<SelectPlotPage> {
  Plot? _selectedPlot;
  // Si deseas un campo de nota rápida, puedes agregar: String? _note;

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
            DropdownButtonFormField<Plot>(
              value: _selectedPlot,
              items: widget.plots
                  .map(
                    (plot) => DropdownMenuItem(
                  value: plot,
                  child: Text(plot.name),
                ),
              )
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
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  // Aquí puedes navegar a la pantalla de agregar parcela
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad de agregar parcela (pendiente)')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Agregar nueva parcela"),
                style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
              ),
            ),
            // Campo de nota opcional (puedes descomentar si quieres usarlo)
            // const SizedBox(height: 8),
            // TextField(
            //   decoration: InputDecoration(
            //     labelText: "Comentario adicional (opcional)",
            //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            //   ),
            //   onChanged: (value) => _note = value,
            // ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_selectedPlot == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Debes seleccionar una parcela.")),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultPage(imageFile: widget.imageFile),
                  ),
                );
              },
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
