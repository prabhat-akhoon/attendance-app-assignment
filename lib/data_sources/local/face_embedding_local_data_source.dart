import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class FaceEmbeddingLocalDataSource {
  final Database _db;
  final Uuid _uuid = const Uuid();

  FaceEmbeddingLocalDataSource(this._db);

  /// Replaces any existing embedding for [staffId] with [embedding].
  Future<void> upsertEmbedding(String staffId, List<double> embedding) async {
    await _db.transaction((txn) async {
      await txn.delete(
        'face_embeddings',
        where: 'staff_id = ?',
        whereArgs: [staffId],
      );
      await txn.insert('face_embeddings', {
        'id': _uuid.v4(),
        'staff_id': staffId,
        'embedding': jsonEncode(embedding),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Future<List<double>?> getEmbeddingForStaff(String staffId) async {
    final rows = await _db.query(
      'face_embeddings',
      where: 'staff_id = ?',
      whereArgs: [staffId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = jsonDecode(rows.first['embedding'] as String) as List<dynamic>;
    return raw.map((e) => (e as num).toDouble()).toList();
  }
}
