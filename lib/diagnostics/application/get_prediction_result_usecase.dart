// send_image_usecase.dart
import 'dart:io';
import '../domain/diagnosis_repository.dart';
import '../domain/diagnosis_result.dart';

class SendImageUseCase {
  final DiagnosisRepository repository;

  SendImageUseCase(this.repository);

  Future<DiagnosisResult> call(File image) {
    return repository.sendImage(image);
  }
}
