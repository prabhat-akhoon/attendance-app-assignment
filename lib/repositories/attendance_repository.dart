import 'dart:io';

import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../data_sources/device/face_detector_data_source.dart';
import '../data_sources/device/face_embedding_data_source.dart';
import '../data_sources/device/location_data_source.dart';
import '../data_sources/device/selfie_storage_data_source.dart';
import '../data_sources/local/attendance_local_data_source.dart';
import '../data_sources/local/face_embedding_local_data_source.dart';
import '../models/attendance_record.dart';
import '../utils/face_match_math.dart';
import '../utils/image_utils.dart';

enum AttendanceOutcome {
  success,
  noFaceDetected,
  multipleFacesDetected,
  faceNotEnrolled,
  faceMismatch,
  locationUnavailable,
  imageUnreadable,
}

class MarkAttendanceResult {
  final AttendanceOutcome outcome;
  final double? matchScore;
  final AttendanceRecord? record;

  const MarkAttendanceResult({
    required this.outcome,
    this.matchScore,
    this.record,
  });

  bool get isSuccess => outcome == AttendanceOutcome.success;
}

/// Staff-side flow: capture a selfie, confirm it matches the staff
/// member's enrolled face, and only then record timestamp + selfie +
/// location. See CLAUDE.md "Face recognition" and "Location".
class AttendanceRepository {
  final FaceDetectorDataSource _faceDetector;
  final FaceEmbeddingDataSource _faceEmbedder;
  final FaceEmbeddingLocalDataSource _embeddingStore;
  final LocationDataSource _locationDataSource;
  final SelfieStorageDataSource _selfieStorage;
  final AttendanceLocalDataSource _attendanceLocalDataSource;
  final Uuid _uuid = const Uuid();

  AttendanceRepository(
    this._faceDetector,
    this._faceEmbedder,
    this._embeddingStore,
    this._locationDataSource,
    this._selfieStorage,
    this._attendanceLocalDataSource,
  );

  Future<MarkAttendanceResult> markAttendance({
    required String staffId,
    required String selfieImagePath,
  }) async {
    final enrolledEmbedding =
        await _embeddingStore.getEmbeddingForStaff(staffId);
    if (enrolledEmbedding == null) {
      return const MarkAttendanceResult(
        outcome: AttendanceOutcome.faceNotEnrolled,
      );
    }

    final faces = await _faceDetector.detectFaces(selfieImagePath);
    if (faces.isEmpty) {
      return const MarkAttendanceResult(
        outcome: AttendanceOutcome.noFaceDetected,
      );
    }
    if (faces.length > 1) {
      return const MarkAttendanceResult(
        outcome: AttendanceOutcome.multipleFacesDetected,
      );
    }

    final box = faces.first.boundingBox;
    final bytes = await File(selfieImagePath).readAsBytes();
    final cropped = cropAndResizeFace(
      fileBytes: bytes,
      left: box.left.round(),
      top: box.top.round(),
      width: box.width.round(),
      height: box.height.round(),
    );
    if (cropped == null) {
      return const MarkAttendanceResult(
        outcome: AttendanceOutcome.imageUnreadable,
      );
    }

    final liveEmbedding = await _faceEmbedder.getEmbedding(cropped);
    final score = cosineSimilarity(enrolledEmbedding, liveEmbedding);

    if (score < kFaceMatchThreshold) {
      return MarkAttendanceResult(
        outcome: AttendanceOutcome.faceMismatch,
        matchScore: score,
      );
    }

    final location = await _locationDataSource.getCurrentLocation();
    if (location == null) {
      return MarkAttendanceResult(
        outcome: AttendanceOutcome.locationUnavailable,
        matchScore: score,
      );
    }

    final savedPath =
        await _selfieStorage.saveSelfie(staffId: staffId, bytes: bytes);

    final record = AttendanceRecord(
      id: _uuid.v4(),
      staffId: staffId,
      timestamp: DateTime.now(),
      selfiePath: savedPath,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      matchScore: score,
    );
    await _attendanceLocalDataSource.insertRecord(record);

    return MarkAttendanceResult(
      outcome: AttendanceOutcome.success,
      matchScore: score,
      record: record,
    );
  }

  Future<List<AttendanceRecord>> getHistoryForStaff(String staffId) =>
      _attendanceLocalDataSource.getRecordsForStaff(staffId);

  Future<List<AttendanceRecord>> getAllRecords() =>
      _attendanceLocalDataSource.getAllRecords();
}
