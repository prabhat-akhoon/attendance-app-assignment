import 'package:flutter/foundation.dart';

import '../repositories/face_enrollment_repository.dart';

class EnrollmentProvider extends ChangeNotifier {
  final FaceEnrollmentRepository _repository;

  EnrollmentProvider(this._repository);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  FaceEnrollmentOutcome? _lastOutcome;
  FaceEnrollmentOutcome? get lastOutcome => _lastOutcome;

  Future<FaceEnrollmentOutcome> enroll({
    required String staffId,
    required String imagePath,
  }) async {
    _isProcessing = true;
    _lastOutcome = null;
    notifyListeners();

    final result = await _repository.enrollFace(
      staffId: staffId,
      imagePath: imagePath,
    );

    _isProcessing = false;
    _lastOutcome = result.outcome;
    notifyListeners();
    return result.outcome;
  }

  void reset() {
    _lastOutcome = null;
    notifyListeners();
  }
}
