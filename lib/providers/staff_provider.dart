import 'package:flutter/foundation.dart';

import '../models/staff.dart';
import '../repositories/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  final StaffRepository _staffRepository;

  StaffProvider(this._staffRepository);

  List<Staff> _staffList = [];
  List<Staff> get staffList => _staffList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadStaff() async {
    _isLoading = true;
    notifyListeners();
    _staffList = await _staffRepository.getAllStaff();
    _isLoading = false;
    notifyListeners();
  }

  /// Returns generated login credentials on success, or null with
  /// [error] set (e.g. duplicate employee ID).
  Future<NewStaffCredentials?> addStaff({
    required String name,
    required String employeeId,
  }) async {
    _error = null;
    try {
      final creds = await _staffRepository.addStaff(
        name: name,
        employeeId: employeeId,
      );
      _staffList = await _staffRepository.getAllStaff();
      notifyListeners();
      return creds;
    } on StaffAlreadyExistsException catch (e) {
      _error = 'Employee ID "${e.employeeId}" already exists';
      notifyListeners();
      return null;
    }
  }

  Future<Staff?> refreshStaff(String staffId) async {
    final staff = await _staffRepository.getStaffById(staffId);
    if (staff != null) {
      _staffList = [
        for (final s in _staffList) s.id == staffId ? staff : s,
      ];
      notifyListeners();
    }
    return staff;
  }
}
