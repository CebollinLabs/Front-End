import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/plots/domain/plot.dart';
import 'package:flutter_frontend_app/plots/application/plot_service.dart';
import 'confirmation_dialog.dart';

class PlotFormPage extends StatefulWidget {
  final PlotService service;
  final Plot? plot; // null para crear, con Plot para editar

  const PlotFormPage({super.key, required this.service, this.plot});

  @override
  State<PlotFormPage> createState() => _PlotFormPageState();
}

class _PlotFormPageState extends State<PlotFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plot?.name ?? '');
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final localContext = context;
      if (widget.plot == null) {
        await widget.service.createPlot(_nameController.text);
        await showConfirmationDialog(localContext, "¡Parcela creada con éxito!");
      } else {
        await widget.service.updatePlot(widget.plot!.id, _nameController.text);
        await showConfirmationDialog(localContext, "¡Parcela actualizada con éxito!");
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      final localContext = context;
      await showConfirmationDialog(localContext, "Ocurrió un error: $e");
      if (!mounted) return;
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plot != null;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'Editar Parcela' : 'Nueva Parcela',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre de parcela'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _onSave,
                    child: Text(isEdit ? 'Guardar Cambios' : 'Crear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
