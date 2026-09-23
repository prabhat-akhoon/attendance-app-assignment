import 'package:flutter/foundation.dart';

import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceProvider(this._repository);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  MarkAttendanceResult? _lastResult;
  MarkAttendanceResult? get lastResult => _lastResult;

  List<AttendanceRecord> _history = [];
  List<AttendanceRecord> get history => _history;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  Future<MarkAttendanceResult> markAttendance({
    required String staffId,
    required String selfieImagePath,
  }) async {
    _isProcessing = true;
    _lastResult = null;
    notifyListeners();

    final result = await _repository.markAttendance(
      staffId: staffId,
      selfieImagePath: selfieImagePath,
    );

    _isProcessing = false;
    _lastResult = result;
    notifyListeners();

    if (result.isSuccess) {
      await loadHistory(staffId);
    }

    return result;
  }

  Future<void> loadHistory(String staffId) async {
    _isLoadingHistory = true;
    notifyListeners();
    _history = await _repository.getHistoryForStaff(staffId);
    _isLoadingHistory = false;
    notifyListeners();
  }

  void reset() {
    _lastResult = null;
    notifyListeners();
  }
}
