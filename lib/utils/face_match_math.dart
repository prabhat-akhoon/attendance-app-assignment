import 'dart:math';

/// Cosine similarity between two equal-length embedding vectors, in
/// [-1, 1] (in practice close to [0, 1] for L2-normalized face
/// embeddings of the same/different people).
double cosineSimilarity(List<double> a, List<double> b) {
  assert(a.length == b.length, 'Embeddings must be the same length');

  double dot = 0, normA = 0, normB = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA == 0 || normB == 0) return 0;
  return dot / (sqrt(normA) * sqrt(normB));
}
