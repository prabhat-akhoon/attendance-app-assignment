import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../core/constants.dart';

/// Crops [fileBytes] to the given face bounding box (already in the
/// decoded image's pixel coordinates, as returned by ML Kit), corrects for
/// EXIF orientation, and resizes to the square input the embedding model
/// expects. Returns null if the bytes aren't a decodable image.
img.Image? cropAndResizeFace({
  required Uint8List fileBytes,
  required int left,
  required int top,
  required int width,
  required int height,
}) {
  final decoded = img.decodeImage(fileBytes);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);

  final clampedLeft = left.clamp(0, oriented.width - 1);
  final clampedTop = top.clamp(0, oriented.height - 1);
  final maxWidth = oriented.width - clampedLeft;
  final maxHeight = oriented.height - clampedTop;
  final clampedWidth = width.clamp(1, maxWidth);
  final clampedHeight = height.clamp(1, maxHeight);

  final cropped = img.copyCrop(
    oriented,
    x: clampedLeft,
    y: clampedTop,
    width: clampedWidth,
    height: clampedHeight,
  );

  return img.copyResize(
    cropped,
    width: kFaceInputSize,
    height: kFaceInputSize,
  );
}
