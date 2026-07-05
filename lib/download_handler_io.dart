import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class DownloadHandler {
  static Future<void> downloadBytes({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
  }
}
