// application/usecases.dart
import '../domain/models.dart';

/// ViewModel simple para la Card
class DiagnosisCardVM {
  final String id;
  final String day;               // YYYY-MM-DD (local)
  final String diseaseLabel;      // nombre legible
  final String confidencePercent; // "99.9%"
  final String plotName;
  final String status;            // texto para badge
  final String imageUrl;          // '' si no hay

  const DiagnosisCardVM({
    required this.id,
    required this.day,
    required this.diseaseLabel,
    required this.confidencePercent,
    required this.plotName,
    required this.status,
    required this.imageUrl,
  });
}

/// Helpers MUY simples (sin intl)
String _formatDayLocal(DateTime utc) {
  final d = utc.toLocal();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$y-$m-$dd';
}

String _formatPercent(double v) => '${(v * 100).toStringAsFixed(1)}%';

String _displayLabel(String className) => className
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

String _statusDisplay(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED': return 'Completado';
    case 'PENDING': return 'Pendiente';
    case 'FAILED': return 'Fallido';
    case 'PROCESSING': return 'Procesando';
    default: return status;
  }
}

DiagnosisCardVM toCardVM(DiagnosisRequest d) {
  // Buscar la predicción que coincide con diagnosisResult; si no, usar top
  final match = d.predictions.firstWhere(
    (p) => p.className == d.diagnosisResult,
    orElse: () => d.topPrediction,
  );

  return DiagnosisCardVM(
    id: d.id,
    day: _formatDayLocal(d.submittedAt),
    diseaseLabel: _displayLabel(match.className),
    confidencePercent: _formatPercent(match.confidence),
    plotName: d.plot.displayName,
    status: _statusDisplay(d.status),
    imageUrl: d.imageUrl ?? '',
  );
}
