/// Test file to verify the immutable data models work correctly
/// Run with: flutter test test/history_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../lib/history/domain/models.dart';
import '../lib/history/domain/examples.dart';

void main() {
  group('DiagnosisRequest Tests', () {
    test('should create from real JSON payload', () {
      final diagnosis = DiagnosisExamples.fromJsonExample();
      
      expect(diagnosis.id, 'c00ac637-9772-4f75-9619-206cbc84583f');
      expect(diagnosis.name, 'cebollin_20250628_175908');
      expect(diagnosis.status, 'COMPLETED');
      expect(diagnosis.diagnosisResult, 'bul_blight');
      expect(diagnosis.predictions.length, 5);
      expect(diagnosis.topPrediction.className, 'bul_blight');
      expect(diagnosis.topPrediction.confidence, 1.0);
      expect(diagnosis.hasImage, true);
      expect(diagnosis.hasComments, false); // Empty string becomes null
    });

    test('should handle null and empty values correctly', () {
      final diagnosis = DiagnosisExamples.withNullsExample();
      
      expect(diagnosis.imageUrl, null);
      expect(diagnosis.comments, null);
      expect(diagnosis.hasImage, false);
      expect(diagnosis.hasComments, false);
    });

    test('should validate confidence ranges', () {
      expect(
        () => Prediction(className: 'test', confidence: 1.5),
        throwsArgumentError,
      );
      
      expect(
        () => Prediction(className: 'test', confidence: -0.1),
        throwsArgumentError,
      );
    });

    test('should validate UUID format', () {
      expect(
        () => Plot(id: 'invalid-uuid', name: 'test'),
        throwsArgumentError,
      );
    });

    test('should validate diagnosis result matches top prediction', () {
      expect(() {
        DiagnosisRequest(
          id: 'c00ac637-9772-4f75-9619-206cbc84583f',
          name: 'test',
          status: 'COMPLETED',
          diagnosisResult: 'wrong_result',
          submittedAt: DateTime.now(),
          predictions: [
            Prediction(className: 'correct_result', confidence: 1.0),
          ],
          plot: Plot(
            id: 'a8ca1680-7949-4003-b094-85dbcd2f4d49',
            name: 'test',
          ),
        );
      }, throwsArgumentError);
    });

    test('should handle ties in predictions correctly', () {
      final diagnosis = DiagnosisExamples.tieExample();
      
      // En caso de empate, debe elegir el que aparece después (mayor índice)
      expect(diagnosis.topPrediction.className, 'fusarium');
      expect(diagnosis.diagnosisResult, 'fusarium');
    });

    test('should maintain data integrity', () {
      final diagnosis = DiagnosisExamples.fromJsonExample();
      expect(DiagnosisExamples.validateDataIntegrity(diagnosis), true);
    });

    test('should serialize and deserialize consistently', () {
      final original = DiagnosisExamples.fromJsonExample();
      final json = original.toJson();
      final roundtrip = DiagnosisRequest.fromJson(json);
      
      expect(original.id, roundtrip.id);
      expect(original.name, roundtrip.name);
      expect(original.status, roundtrip.status);
      expect(original.diagnosisResult, roundtrip.diagnosisResult);
      expect(original.predictions.length, roundtrip.predictions.length);
      expect(original.plot.id, roundtrip.plot.id);
    });

    test('should format dates correctly', () {
      final diagnosis = DiagnosisExamples.fromJsonExample();
      
      // Verificar que las fechas se formatean correctamente
      final localDate = diagnosis.toLocalDate();
      final localDateTime = diagnosis.toLocalDateTime();
      
      expect(localDate, matches(r'\d{2}/\d{2}/\d{4}'));
      expect(localDateTime, matches(r'\d{2}/\d{2}/\d{4} \d{2}:\d{2}'));
    });

    test('should display prediction percentages correctly', () {
      final diagnosis = DiagnosisExamples.fromJsonExample();
      final topPred = diagnosis.topPrediction;
      
      expect(topPred.confidencePercentage, '100.0%');
      
      // Test with partial confidence
      final partialPred = Prediction(className: 'test', confidence: 0.756);
      expect(partialPred.confidencePercentage, '75.6%');
    });

    test('should handle status display correctly', () {
      final diagnosis = DiagnosisExamples.fromJsonExample();
      expect(diagnosis.statusDisplay, 'Completado');
      
      final mockPending = TestUtils.createMockDiagnosis(status: 'PENDING');
      expect(mockPending.statusDisplay, 'Pendiente');
      
      final mockProcessing = TestUtils.createMockDiagnosis(status: 'PROCESSING');
      expect(mockProcessing.statusDisplay, 'Procesando');
    });

    test('should create valid mock data', () {
      final mock = TestUtils.createMockDiagnosis();
      
      expect(mock.id, isNotEmpty);
      expect(mock.name, contains('test_sample_'));
      expect(mock.status, 'COMPLETED');
      expect(mock.predictions.length, 2);
      expect(DiagnosisExamples.validateDataIntegrity(mock), true);
    });

    test('serialization roundtrip should work', () {
      final mock = TestUtils.createMockDiagnosis();
      expect(TestUtils.testSerialization(mock), true);
      
      final real = DiagnosisExamples.fromJsonExample();
      expect(TestUtils.testSerialization(real), true);
    });
  });

  group('Prediction Tests', () {
    test('should create valid prediction', () {
      final pred = Prediction(className: 'healthy_leaf', confidence: 0.85);
      
      expect(pred.className, 'healthy_leaf');
      expect(pred.confidence, 0.85);
      expect(pred.displayName, 'Hoja Saludable');
      expect(pred.confidencePercentage, '85.0%');
    });

    test('should handle unknown class names', () {
      final pred = Prediction(className: 'unknown_disease', confidence: 0.5);
      expect(pred.displayName, 'Unknown Disease'); // Título formateado
    });

    test('should validate empty class names', () {
      expect(
        () => Prediction(className: '', confidence: 0.5),
        throwsArgumentError,
      );
    });
  });

  group('Plot Tests', () {
    test('should create valid plot', () {
      final plot = Plot(
        id: 'a8ca1680-7949-4003-b094-85dbcd2f4d49',
        name: 'Mi Cultivo',
      );
      
      expect(plot.id, 'a8ca1680-7949-4003-b094-85dbcd2f4d49');
      expect(plot.name, 'Mi Cultivo');
      expect(plot.displayName, 'Mi Cultivo');
    });

    test('should handle empty plot names', () {
      final plot = Plot(
        id: 'a8ca1680-7949-4003-b094-85dbcd2f4d49',
        name: '',
      );
      
      expect(plot.displayName, 'Sin nombre');
    });

    test('should trim whitespace from names', () {
      final plot = Plot(
        id: 'a8ca1680-7949-4003-b094-85dbcd2f4d49',
        name: '  Cultivo con espacios  ',
      );
      
      expect(plot.displayName, 'Cultivo con espacios');
    });
  });

  group('Performance Tests', () {
    test('should handle large number of predictions efficiently', () {
      final largePredictions = List.generate(100, (i) =>
        Prediction(className: 'class_$i', confidence: (100 - i) / 100.0)
      );
      
      final diagnosis = DiagnosisRequest(
        id: 'c00ac637-9772-4f75-9619-206cbc84583f',
        name: 'performance_test',
        status: 'COMPLETED',
        diagnosisResult: 'class_0', // Highest confidence
        submittedAt: DateTime.now(),
        predictions: largePredictions,
        plot: Plot(
          id: 'a8ca1680-7949-4003-b094-85dbcd2f4d49',
          name: 'Test Plot',
        ),
      );
      
      expect(diagnosis.predictions.length, 100);
      expect(diagnosis.topPrediction.className, 'class_0');
      expect(diagnosis.topPrediction.confidence, 1.0);
    });
  });
}