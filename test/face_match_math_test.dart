import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_app/utils/face_match_math.dart';

void main() {
  test('identical embeddings have similarity 1.0', () {
    final v = [0.5, 0.5, 0.5, 0.5];
    expect(cosineSimilarity(v, v), closeTo(1.0, 1e-9));
  });

  test('opposite embeddings have similarity -1.0', () {
    final a = [1.0, 0.0];
    final b = [-1.0, 0.0];
    expect(cosineSimilarity(a, b), closeTo(-1.0, 1e-9));
  });

  test('orthogonal embeddings have similarity 0.0', () {
    final a = [1.0, 0.0];
    final b = [0.0, 1.0];
    expect(cosineSimilarity(a, b), closeTo(0.0, 1e-9));
  });

  test('zero vector returns 0 instead of dividing by zero', () {
    final a = [0.0, 0.0];
    final b = [1.0, 1.0];
    expect(cosineSimilarity(a, b), 0.0);
  });
}
