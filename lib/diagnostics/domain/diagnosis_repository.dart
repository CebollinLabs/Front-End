// domain/diagnosis_repository.dart
import 'dart:io';
import 'diagnosis_result.dart';

abstract class DiagnosisRepository {
  Future<DiagnosisResult> sendImage(File image);
}