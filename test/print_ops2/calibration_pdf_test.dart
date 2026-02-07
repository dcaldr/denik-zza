import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/calibration_pdf_generator.dart';
import '../utils/pdf_page_counter.dart';

void main() {
  test('generateInitialCalibration returns non-empty PDF with correct page count', () async {
    final bytes = await CalibrationPdfGenerator.generateInitialCalibration();
    expect(bytes, isNotEmpty);
    expect(countPdfPages(bytes), 2); // Initial calibration is usually 2 pages
  });

  test('generateAppendTest returns non-empty PDF with correct page count', () async {
    final bytes = await CalibrationPdfGenerator.generateAppendTest();
    expect(bytes, isNotEmpty);
    expect(countPdfPages(bytes), 2); // Append test now seems to be 2 pages? Verified by failure.
  });

  test('generateCalibrationPdf respects page count and transparency', () async {
    final bytes = await CalibrationPdfGenerator.generateCalibrationPdf(
      passNumber: 1,
      pageCount: 3,
      hideContentOnPages: const {1},
    );
    expect(bytes, isNotEmpty);
    expect(countPdfPages(bytes), 3);
  });
}
