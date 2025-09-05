import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_header_section.dart';

class PrintPdfHeader implements PdfSection {
  final PdfHeaderSection headerSection;

  PrintPdfHeader(this.headerSection);

  pw.Widget buildHeader() {
    return headerSection.buildHeader();
  }

  @override
  pw.Widget buildSection(bool append) {
    return buildHeader();
  }
}