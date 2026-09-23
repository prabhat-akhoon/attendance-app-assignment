import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists selfie JPEGs to app-private storage. Only the returned file
/// path is stored in SQLite — the bytes live on disk, not in the DB.
class SelfieStorageDataSource {
  Future<String> saveSelfie({
    required String staffId,
    required Uint8List bytes,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final staffDir = Directory(p.join(docsDir.path, 'selfies', staffId));
    if (!await staffDir.exists()) {
      await staffDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(p.join(staffDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
