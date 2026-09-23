import 'package:sqflite/sqflite.dart';

import '../../models/staff.dart';

class StaffLocalDataSource {
  final Database _db;

  StaffLocalDataSource(this._db);

  Future<void> insertStaff(Staff staff) async {
    await _db.insert('staff', staff.toMap());
  }

  Future<List<Staff>> getAllStaff() async {
    final rows = await _db.query('staff', orderBy: 'created_at DESC');
    return rows.map(Staff.fromMap).toList();
  }

  Future<Staff?> getStaffById(String id) async {
    final rows = await _db.query(
      'staff',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Staff.fromMap(rows.first);
  }

  Future<bool> employeeIdExists(String employeeId) async {
    final rows = await _db.query(
      'staff',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> updateFaceEnrolledAt(String staffId, DateTime enrolledAt) async {
    await _db.update(
      'staff',
      {'face_enrolled_at': enrolledAt.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [staffId],
    );
  }
}
