import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/constants.dart';

/// Wraps the bundled MobileFaceNet TFLite model. Turns a cropped,
/// 112x112 face image into an L2-normalized 192-d embedding vector.
/// Two embeddings from the same person are close together (high cosine
/// similarity); different people are far apart. See CLAUDE.md.
class FaceEmbeddingDataSource {
  Interpreter? _interpreter;

  Future<void> _ensureLoaded() async {
    _interpreter ??= await Interpreter.fromAsset(kFaceModelAssetPath);
  }

  Future<List<double>> getEmbedding(img.Image faceImage) async {
    await _ensureLoaded();

    final input = [_imageToInputPlane(faceImage)];
    final output = [List<double>.filled(kFaceEmbeddingLength, 0.0)];

    _interpreter!.run(input, output);

    return _l2Normalize(output[0]);
  }

  List<List<List<double>>> _imageToInputPlane(img.Image image) {
    return List.generate(image.height, (y) {
      return List.generate(image.width, (x) {
        final pixel = image.getPixel(x, y);
        return [
          (pixel.r - 127.5) / 128.0,
          (pixel.g - 127.5) / 128.0,
          (pixel.b - 127.5) / 128.0,
        ];
      });
    });
  }

  List<double> _l2Normalize(List<double> vector) {
    var sumSquares = 0.0;
    for (final value in vector) {
      sumSquares += value * value;
    }
    final norm = sqrt(sumSquares);
    if (norm == 0) return vector;
    return vector.map((v) => v / norm).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
