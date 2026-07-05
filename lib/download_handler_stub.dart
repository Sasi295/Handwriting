import 'package:flutter/foundation.dart';

abstract class DownloadHandler {
  static Future<void> downloadBytes({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    if (kDebugMode) {
      debugPrint('Download not supported on this platform: $fileName');
    }
  }
}
