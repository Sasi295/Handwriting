import 'dart:convert';
import 'package:web/web.dart' as web;

abstract class DownloadHandler {
  static Future<void> downloadBytes({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
    web.HTMLAnchorElement()
      ..href = dataUrl
      ..download = fileName
      ..click();
  }
}
