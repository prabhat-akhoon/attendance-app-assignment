import 'package:uuid/uuid.dart';

import '../data_sources/local/auth_local_data_source.dart';
import '../data_sources/local/staff_local_data_source.dart';
import '../models/staff.dart';

class StaffAlreadyExistsException implements Exception {
  final String employeeId;
  StaffAlreadyExistsException(this.employeeId);
}

/// Returned right after [StaffRepository.addStaff] so the UI can show the
/// generated login once (username == password == employeeId).
class NewStaffCredentials {
  final Staff staff;
  final String username;
  final String password;

  const NewStaffCredentials(this.staff, this.username, this.password);
}

class StaffRepository {
  final StaffLocalDataSource _staffLocalDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final Uuid _uuid = const Uuid();

  StaffRepository(this._staffLocalDataSource, this._authLocalDataSource);

  Future<List<Staff>> getAllStaff() => _staffLocalDataSource.getAllStaff();

  Future<Staff?> getStaffById(String id) =>
      _staffLocalDataSource.getStaffById(id);

  /// Creates a staff profile and an auto-generated login. See CLAUDE.md
  /// "Auth" for why username/password are both the employee ID.
  Future<NewStaffCredentials> addStaff({
    required String name,
    required String employeeId,
  }) async {
    final trimmedId = employeeId.trim();
    if (await _staffLocalDataSource.employeeIdExists(trimmedId)) {
      throw StaffAlreadyExistsException(trimmedId);
    }

    final staff = Staff(
      id: _uuid.v4(),
      employeeId: trimmedId,
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await _staffLocalDataSource.insertStaff(staff);

    await _authLocalDataSource.insertStaffLogin(
      id: _uuid.v4(),
      username: trimmedId,
      password: trimmedId,
      staffId: staff.id,
    );

    return NewStaffCredentials(staff, trimmedId, trimmedId);
  }
}
