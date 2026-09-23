/// App-wide tunables. Kept in one place so thresholds/sizes are easy to find.
library;

/// Cosine similarity threshold above which two face embeddings are
/// considered the same person. See CLAUDE.md "Face recognition" section.
const double kFaceMatchThreshold = 0.60;

/// MobileFaceNet expects a square 112x112 RGB input.
const int kFaceInputSize = 112;

/// Path (relative to app assets) of the bundled face embedding model.
const String kFaceModelAssetPath = 'assets/ml/mobilefacenet.tflite';

/// Output embedding length produced by the bundled MobileFaceNet model.
const int kFaceEmbeddingLength = 192;

const String kDatabaseName = 'attendance_app.db';
const int kDatabaseVersion = 1;

/// Seeded dummy admin credentials (brief explicitly allows dummy creds).
const String kSeedAdminUsername = 'admin';
const String kSeedAdminPassword = 'admin123';
