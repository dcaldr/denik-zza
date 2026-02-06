import 'package:pdf/widgets.dart' as pw;

import 'pdf_header_section.dart';

class PrintPdfHeader {
  final PdfHeaderSection headerSection;

  PrintPdfHeader(this.headerSection);

  pw.Widget buildHeader() {
    return headerSection.buildHeader();
  }
}
