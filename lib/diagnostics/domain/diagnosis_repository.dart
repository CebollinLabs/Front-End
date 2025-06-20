import 'dart:io';
import 'diagnosis_result.dart';

abstract class DiagnosisRepository {
  Future<DiagnosisResult> sendDiagnosisRequest({
    required File image,
    required String plotId,
    String name = '',
    String comments = '',
  });
}
