import 'package:sqflite/sqflite.dart';

/// Raw CRUD against the `app_users` table. No password-checking logic here
/// — that belongs in AuthRepository.
class AuthLocalDataSource {
  final Database _db;

  AuthLocalDataSource(this._db);

  Future<Map<String, Object?>?> getUserByUsername(String username) async {
    final rows = await _db.query(
      'app_users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertStaffLogin({
    required String id,
    required String username,
    required String password,
    required String staffId,
  }) async {
    await _db.insert('app_users', {
      'id': id,
      'username': username,
      'password': password,
      'role': 'staff',
      'staff_id': staffId,
    });
  }
}
