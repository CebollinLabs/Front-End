import 'plot.dart';

abstract class PlotRepository {
  Future<List<Plot>> getAll();
  Future<void> create(String name);
  Future<void> update(String id, String name);
}
