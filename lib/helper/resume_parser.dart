import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'docx_parser.dart';

class ResumeParser {
  static Future<String> extractText(String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return _extractPdfText(filePath);
      case 'docx':
        return DocxParser.extractText(filePath);
      case 'txt':
        return File(filePath).readAsString();
      case 'doc':
        throw UnsupportedError(
          'Legacy .doc files are not supported yet. Please upload a PDF, DOCX, or TXT resume.',
        );
      default:
        throw UnsupportedError(
          'Unsupported file format. Please upload a PDF, DOCX, or TXT resume.',
        );
    }
  }

  static Future<String> _extractPdfText(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    try {
      return PdfTextExtractor(document).extractText();
    } finally {
      document.dispose();
    }
  }
}
