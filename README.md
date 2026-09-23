# Attendance App

Selfie-based face recognition attendance app for Admin and Staff, built for
Android with Flutter.

## Tech stack & architecture

- **Flutter** (Material 3, `useMaterial3: true`)
- **State management:** Provider
- **Persistence:** SQLite via `sqflite` (staff, face embeddings, attendance
  records, dummy logins); selfie images stored as files on disk, only the
  path is stored in the DB
- **Face detection:** `google_mlkit_face_detection` — locates the face,
  checks exactly one face is present
- **Face recognition/matching:** `tflite_flutter` running a bundled
  **MobileFaceNet** model (`assets/ml/mobilefacenet.tflite`, 112×112 input,
  192‑d embedding) — enrolled and live embeddings are compared with cosine
  similarity against a threshold (`kFaceMatchThreshold` in
  `lib/core/constants.dart`, default `0.60`)
- **Camera:** `camera`
- **Location:** `geolocator` (coordinates) + `geocoding` (best-effort
  reverse geocoded address)

**4-layer architecture**, strictly downward-dependent:

```
Screens / Widgets  →  Providers (ChangeNotifier)  →  Repositories  →  Data Sources
```

- `lib/models/` — plain Dart value classes shared across all layers
- `lib/data_sources/local/` — sqflite tables (one data source per table)
- `lib/data_sources/device/` — camera, ML Kit, TFLite, geolocator/geocoding,
  file storage (one data source per external system)
- `lib/repositories/` — business rules (auth check, face-match threshold,
  attendance assembly), orchestrate one or more data sources
- `lib/providers/` — per-screen `ChangeNotifier`s, call repositories and
  expose UI state
- `lib/screens/`, `lib/widgets/` — Material 3 UI, composable widgets

Full rationale for these decisions (including alternatives considered for
face recognition) is in [`CLAUDE.md`](./CLAUDE.md).

## How to run

Android only (not configured for iOS/web/desktop).

1. Install Flutter (this project targets Flutter 3.47+ / Dart 3.13+) and
   the Android SDK.
2. From the project root:
   ```
   flutter pub get
   flutter run
   ```
   Pick a connected device or emulator when prompted. The bundled face
   model (`assets/ml/mobilefacenet.tflite`) is already committed, so no
   extra download is needed.
3. Grant camera and location permissions when prompted (camera is
   requested by the `camera` plugin on first use; location by
   `geolocator` when marking attendance).

Run tests with:
```
flutter test
```

## Demo credentials

- **Admin** — `admin` / `admin123` (seeded on first launch)
- **Staff** — created by the admin via *Add staff*. The login is
  auto-generated as **username = password = employee ID**, shown once in a
  dialog right after the staff member is added.

## Assumptions & limitations

- **Dummy auth by design.** Credentials are plaintext in a local SQLite
  table (per the assignment's "dummy credentials are fine"). Not a
  real-world auth pattern.
- **No liveness detection.** A printed photo or a phone screen held up to
  the camera could pass the face match — there's no blink/liveness check.
  Noted as a deliberate scope cut, not an oversight.
- **One enrolled face per staff member.** Re-enrolling overwrites the
  previous embedding rather than keeping multiple samples.
- **Location is required to mark attendance.** If GPS/permission is
  unavailable, attendance is not recorded (it's treated as an incomplete
  attendance event, not a partial success) — matches the requirement that
  location must be stored.
- **Only successful attendance is persisted.** Failed match attempts (no
  face, wrong face, etc.) are shown in the UI but not written to the
  database — there's no audit log of rejected attempts.
- **Reverse geocoding is best-effort.** If `geocoding` can't resolve an
  address (e.g. no network), the raw latitude/longitude is stored and
  shown instead.
- **Local-only, single-device.** No backend, sync, or multi-device
  support — all data lives in the app's local SQLite database and file
  storage.
- **Face match threshold is a tunable constant**, not calibrated against a
  real dataset — `kFaceMatchThreshold = 0.60` in `lib/core/constants.dart`
  may need adjustment for real-world lighting/camera conditions.
