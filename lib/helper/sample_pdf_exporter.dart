import 'dart:io';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class SamplePdfExporter {
  static Future<String> exportCustomRoleGuide({
    required String roleName,
    required String company,
    required String location,
    required String level,
    required String jobDescription,
    required String resumeExample,
    List<String> focusPoints = const [],
  }) async {
    final document = PdfDocument();
    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    final headingFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final page = document.pages.add();
    final pageSize = page.getClientSize();
    double top = 0;

    page.graphics.drawString(
      '$roleName Example Guide',
      titleFont,
      bounds: Rect.fromLTWH(0, top, pageSize.width, 30),
    );
    top += 32;

    page.graphics.drawString(
      '$company | $location | $level',
      bodyFont,
      bounds: Rect.fromLTWH(0, top, pageSize.width, 20),
    );
    top += 28;

    if (focusPoints.isNotEmpty) {
      page.graphics.drawString(
        'Focus Areas: ${focusPoints.join(", ")}',
        bodyFont,
        bounds: Rect.fromLTWH(0, top, pageSize.width, 20),
      );
      top += 22;
    }

    top = _drawSection(
      page: page,
      top: top,
      pageWidth: pageSize.width,
      heading: 'Example Job Description',
      content: jobDescription,
      headingFont: headingFont,
      bodyFont: bodyFont,
    );

    _drawSection(
      page: page,
      top: top + 12,
      pageWidth: pageSize.width,
      heading: 'Example Resume',
      content: resumeExample,
      headingFont: headingFont,
      bodyFont: bodyFont,
    );

    final bytes = await document.save();
    document.dispose();

    final directory = await Directory.systemTemp.createTemp('skilllens_role_guides');
    final safeName = roleName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final file = File('${directory.path}\\${safeName}_guide.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static double _drawSection({
    required PdfPage page,
    required double top,
    required double pageWidth,
    required String heading,
    required String content,
    required PdfFont headingFont,
    required PdfFont bodyFont,
  }) {
    page.graphics.drawString(
      heading,
      headingFont,
      bounds: Rect.fromLTWH(0, top, pageWidth, 20),
    );
    top += 24;

    final layoutResult = PdfTextElement(
      text: content,
      font: bodyFont,
    ).draw(
      page: page,
      bounds: Rect.fromLTWH(0, top, pageWidth, page.getClientSize().height - top),
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
    );

    return layoutResult?.bounds.bottom ?? top;
  }
}
