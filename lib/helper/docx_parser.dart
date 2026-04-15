import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';

class DocxParser {
  /// Extracts plain text from a .docx file
  static Future<String> extractText(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();

    // Decode the .docx as zip
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find the document.xml
    final documentFile = archive.firstWhere(
          (file) => file.name == 'word/document.xml',
      orElse: () => throw Exception("document.xml not found"),
    );

    final xmlString = String.fromCharCodes(documentFile.content as List<int>);

    // Parse XML and extract all <w:t> nodes (text)
    final xmlDoc = XmlDocument.parse(xmlString);
    final texts = xmlDoc.findAllElements('w:t').map((node) => node.text);

    return texts.join(' ');
  }
}
