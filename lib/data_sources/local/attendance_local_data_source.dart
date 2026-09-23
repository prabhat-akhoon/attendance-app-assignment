import 'package:sqflite/sqflite.dart';

import '../../models/attendance_record.dart';

class AttendanceLocalDataSource {
  final Database _db;

  AttendanceLocalDataSource(this._db);

  Future<void> insertRecord(AttendanceRecord record) async {
    await _db.insert('attendance_records', record.toMap());
  }

  Future<List<AttendanceRecord>> getRecordsForStaff(String staffId) async {
    final rows = await _db.query(
      'attendance_records',
      where: 'staff_id = ?',
      whereArgs: [staffId],
      orderBy: 'timestamp DESC',
    );
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<List<AttendanceRecord>> getAllRecords() async {
    final rows = await _db.query('attendance_records', orderBy: 'timestamp DESC');
    return rows.map(AttendanceRecord.fromMap).toList();
  }
}
