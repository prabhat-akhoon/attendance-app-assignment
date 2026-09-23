import 'dart:io';

import '../data_sources/device/face_detector_data_source.dart';
import '../data_sources/device/face_embedding_data_source.dart';
import '../data_sources/local/face_embedding_local_data_source.dart';
import '../data_sources/local/staff_local_data_source.dart';
import '../utils/image_utils.dart';

enum FaceEnrollmentOutcome {
  success,
  noFaceDetected,
  multipleFacesDetected,
  imageUnreadable,
}

class FaceEnrollmentResult {
  final FaceEnrollmentOutcome outcome;

  const FaceEnrollmentResult(this.outcome);

  bool get isSuccess => outcome == FaceEnrollmentOutcome.success;
}

/// Admin-side flow: capture one selfie of a staff member, turn it into a
/// face embedding, store it. See CLAUDE.md "Face recognition".
class FaceEnrollmentRepository {
  final FaceDetectorDataSource _faceDetector;
  final FaceEmbeddingDataSource _faceEmbedder;
  final FaceEmbeddingLocalDataSource _embeddingStore;
  final StaffLocalDataSource _staffLocalDataSource;

  FaceEnrollmentRepository(
    this._faceDetector,
    this._faceEmbedder,
    this._embeddingStore,
    this._staffLocalDataSource,
  );

  Future<FaceEnrollmentResult> enrollFace({
    required String staffId,
    required String imagePath,
  }) async {
    final faces = await _faceDetector.detectFaces(imagePath);
    if (faces.isEmpty) {
      return const FaceEnrollmentResult(FaceEnrollmentOutcome.noFaceDetected);
    }
    if (faces.length > 1) {
      return const FaceEnrollmentResult(
        FaceEnrollmentOutcome.multipleFacesDetected,
      );
    }

    final box = faces.first.boundingBox;
    final bytes = await File(imagePath).readAsBytes();
    final cropped = cropAndResizeFace(
      fileBytes: bytes,
      left: box.left.round(),
      top: box.top.round(),
      width: box.width.round(),
      height: box.height.round(),
    );
    if (cropped == null) {
      return const FaceEnrollmentResult(FaceEnrollmentOutcome.imageUnreadable);
    }

    final embedding = await _faceEmbedder.getEmbedding(cropped);
    await _embeddingStore.upsertEmbedding(staffId, embedding);
    await _staffLocalDataSource.updateFaceEnrolledAt(staffId, DateTime.now());

    return const FaceEnrollmentResult(FaceEnrollmentOutcome.success);
  }
}
