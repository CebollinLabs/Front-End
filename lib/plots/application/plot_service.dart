import 'package:flutter_frontend_app/plots/domain/plot.dart' as plots;
import 'package:flutter_frontend_app/plots/domain/plot_repository.dart';

class PlotService {
  final PlotRepository repo;
  PlotService(this.repo);

  Future<List<plots.Plot>> getAllPlots() => repo.getAll();
  Future<void> createPlot(String name) => repo.create(name);
  Future<void> updatePlot(String id, String name) => repo.update(id, name);
}
