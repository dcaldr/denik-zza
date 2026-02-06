import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/calibration_pdf_generator.dart';

void main() {
  test('generateInitialCalibration returns non-empty PDF bytes', () async {
    final bytes = await CalibrationPdfGenerator.generateInitialCalibration();
    expect(bytes, isNotEmpty);
  });

  test('generateAppendTest returns non-empty PDF bytes', () async {
    final bytes = await CalibrationPdfGenerator.generateAppendTest();
    expect(bytes, isNotEmpty);
  });

  test('generateCalibrationPdf supports transparent pages', () async {
    final bytes = await CalibrationPdfGenerator.generateCalibrationPdf(
      passNumber: 1,
      pageCount: 2,
      hideContentOnPages: const {1},
    );
    expect(bytes, isNotEmpty);
  });
}
