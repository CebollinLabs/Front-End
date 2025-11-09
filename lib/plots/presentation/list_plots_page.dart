import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/plots/domain/plot.dart';
import 'package:flutter_frontend_app/plots/application/plot_service.dart';
import 'plot_form_page.dart';

class ListPlotsPage extends StatefulWidget {
  final PlotService service;
  const ListPlotsPage({super.key, required this.service});

  @override
  State<ListPlotsPage> createState() => _ListPlotsPageState();
}

class _ListPlotsPageState extends State<ListPlotsPage> {
  late Future<List<Plot>> _plotsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPlots();
  }

  void _refreshPlots() {
    setState(() {
      _plotsFuture = widget.service.getAllPlots();
    });
  }

  void _openPlotForm({Plot? plot}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => PlotFormPage(
        service: widget.service,
        plot: plot,
      ),
    );
    if (result == true) _refreshPlots();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.green.shade200;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tus parcelas",
                style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Plot>>(
                future: _plotsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final plots = snapshot.data ?? [];
                  if (plots.isEmpty) {
                    return const Center(
                      child: Text("Aún no tienes parcelas registradas.",
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.separated(
                    itemCount: plots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final plot = plots[idx];
                      return Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: borderColor, width: 1.2)),
                          title: Text(
                            plot.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _openPlotForm(plot: plot),
                            tooltip: "Editar parcela",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 60, width: 60,
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => _openPlotForm(),
          tooltip: 'Agregar parcela',
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          elevation: 3,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
