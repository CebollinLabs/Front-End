import 'dart:io';
import '../domain/diagnosis_repository.dart';
import '../domain/diagnosis_result.dart';

class SendDiagnosisRequestUseCase {
  final DiagnosisRepository repository;

  SendDiagnosisRequestUseCase(this.repository);

  Future<DiagnosisResult> call({
    required File image,
    required String plotId,
    String name = '',
    String comments = '',
  }) {
    return repository.sendDiagnosisRequest(
      image: image,
      plotId: plotId,
      name: name,
      comments: comments,
    );
  }
}
