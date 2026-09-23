import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Thin wrapper around ML Kit's on-device face detector. Detects *where*
/// faces are and basic pose/landmarks — it does not identify a person.
/// Identity matching happens in [FaceEmbeddingDataSource] + the
/// repositories that compare embeddings.
class FaceDetectorDataSource {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
    ),
  );

  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return _detector.processImage(inputImage);
  }

  void dispose() {
    _detector.close();
  }
}
