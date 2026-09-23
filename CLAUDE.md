# attendance_app — CLAUDE.md

Selfie-based face recognition attendance app. Admin manages staff and enrols
faces; Staff mark attendance only when their live selfie matches their
enrolled face. Flutter, SQLite (sqflite), Material 3, Provider.

## Architecture: 4 layers, strict downward dependency

```
Screens / Widgets   (Flutter UI, Material 3, composable)
        ↓ watches / calls
Providers           (ChangeNotifier — UI state + orchestration trigger)
        ↓ calls
Repositories         (business rules, orchestrates 1+ data sources)
        ↓ calls
Data Sources         (thin wrapper around ONE external system: DB, camera,
                      ML Kit, TFLite, filesystem, GPS)
```

`Models` are plain Dart value classes used across every layer — they belong
to no single layer.

**Rule of thumb when adding code:** if it talks to a plugin/package
directly (`sqflite`, `camera`, `geolocator`, `tflite_flutter`,
`google_mlkit_face_detection`, `path_provider`), it belongs in a
**data source**. If it makes a business decision (is this a match? is this
enrolment valid? what counts as "attendance"?), it belongs in a
**repository**. Providers never call packages directly and never contain
matching/threshold logic — they call a repository method and expose the
result as state.

### Layer directory map

```
lib/
  core/            app-wide constants, theme, DB schema constants
  models/          Staff, AppUser, AttendanceRecord — plain Dart classes
  data_sources/
    local/         sqflite: AppDatabase + one data source per table
    device/        camera, ML Kit, TFLite, geolocator/geocoding, file storage
  repositories/    AuthRepository, StaffRepository,
                   FaceEnrollmentRepository, AttendanceRepository
  providers/       AuthProvider, StaffProvider, EnrollmentProvider,
                   AttendanceProvider
  screens/         auth/, admin/, staff/ — route-level pages
  widgets/         composable, stateless-where-possible reusable UI
  utils/           pure functions only (image cropping, cosine similarity)
```

A repository is only ever constructed with the data source(s) it needs
(constructor injection), and a provider is only ever constructed with the
repository it needs. `main.dart` wires the whole graph with `MultiProvider`.
No service locator, no global singletons except `AppDatabase` (a genuine
single shared resource — the open sqflite connection).

## Why this stack

- **State management: Provider.** Specified by the assignment. Each screen
  cluster gets its own `ChangeNotifier` (`AuthProvider`, `StaffProvider`,
  `EnrollmentProvider`, `AttendanceProvider`) rather than one giant app
  state — keeps rebuild scope small and keeps each provider's public API
  readable as "what can this screen do".
- **Persistence: sqflite.** Local-only is explicitly allowed by the brief,
  and an attendance app's data (staff, embeddings, attendance log) is
  inherently row/relational, which suits SQL better than a document store.
  Selfie **images are stored as files**, not BLOBs — only the file path is
  stored in SQLite (`AttendanceRecord.selfiePath`). Keeps the DB small and
  lets the OS/filesystem do what it's good at.

## Face recognition: how matching actually works

This is the core design decision of the assignment, so it's spelled out in
full.

**Two-stage pipeline, both stages fully on-device / offline:**

1. **Face detection & quality gate** — `google_mlkit_face_detection`
   (`data_sources/device/face_detector_data_source.dart`). Confirms
   exactly one face is present, checks head rotation isn't extreme, and
   returns the bounding box used to crop the face. This package detects
   faces and landmarks; it does **not** identify or compare faces — that's
   stage 2.
2. **Face embedding & matching** — `tflite_flutter` running a bundled
   **MobileFaceNet** model (`assets/ml/mobilefacenet.tflite`, 112×112×3
   input, 192-d output, ~5.2 MB). The cropped face is resized/normalized
   and passed through the model to get a 192-d embedding, which is
   L2-normalized. Two faces are considered the same person when the
   **cosine similarity** between their embeddings exceeds
   `kFaceMatchThreshold` (`core/constants.dart`, default `0.60` — typical
   working range for MobileFaceNet is 0.5–0.7; tune this constant if you
   see false accepts/rejects on real devices).

**Enrolment** (`FaceEnrollmentRepository`) runs stage 1 + stage 2 once on
an admin-captured selfie and stores the resulting embedding
(`face_embeddings` table, one row per staff member — re-enrolling
overwrites it).

**Marking attendance** (`AttendanceRepository`) runs stage 1 + stage 2 on
a freshly captured staff selfie, loads that staff's stored embedding,
compares, and only proceeds to write an attendance record if the
similarity clears the threshold. On a rejection, **nothing is persisted**
— the UI shows the failure reason (no face / multiple faces / face
mismatch) and lets the user retry. Decision: only *successful* matches are
recorded, since the requirement is "record attendance," not "log every
attempt"; a failed-attempt audit log would be a reasonable extension but is
out of scope here.

### Why MobileFaceNet + ML Kit instead of alternatives considered

- **ML Kit face detection alone** (no embedding model) — rejected. ML Kit
  gives bounding boxes/landmarks/contours, not an identity vector, so
  "does this face match that face" would have to be approximated by
  landmark geometry, which is unreliable across pose/lighting and isn't
  really "face recognition."
- **Cloud face-matching API** (AWS Rekognition, Azure Face, etc.) —
  rejected. Requires network + a backend + API keys for a take-home
  assignment that explicitly allows local-only, and breaks the "mark
  attendance offline" use case.
- **MobileFaceNet TFLite (chosen)** — a small (~5 MB), well-established,
  on-device face embedding model, standard in offline Flutter
  face-recognition apps. Fully offline, no keys, fast enough on-device.
  Bundled at `assets/ml/mobilefacenet.tflite`
  (BSD-3-Clause-licensed source: `MCarlomagno/FaceRecognitionAuth`).

### Known limitation (documented, not fixed)

No **liveness detection** — a printed photo or a phone screen held up to
the camera could pass the match check. A real deployment would add a
liveness/anti-spoofing signal (blink detection via ML Kit's eye-open
probability across frames, or a dedicated liveness model). Out of scope
here; noted so it isn't mistaken for an oversight.

## Auth (dummy, as the brief permits)

- One seeded admin user: `admin` / `admin123`.
- When an Admin adds a staff member, a staff login is auto-created:
  **username = employee ID, password = employee ID**. This is the
  simplest possible dummy scheme and is intentional — it means "add staff"
  produces a working login with no extra admin step, and the credential is
  shown once on the Add Staff success screen. **Not secure**, by design,
  per "dummy credentials are fine" in the brief. Passwords are stored
  as plain text in `app_users` for the same reason — do not carry this
  pattern into a real app.
- A staff login is what tells the app *which* staff row a "mark
  attendance" attempt is for; the face match is what proves the person
  behind the camera is actually that staff member. Two factors, not one.

## Location

`geolocator` for the device coordinates (`data_sources/device/location_data_source.dart`),
`geocoding` for a best-effort human-readable address from those
coordinates. If GPS is unavailable, attendance marking fails with a clear
"location unavailable" reason rather than silently storing `null` —
requirement 5 says location must be stored, so a record without one is
treated as an incomplete attendance event, not a partial success.

## Camera controller: the one deliberate layering exception

`CameraController` (from `package:camera`) is instantiated and owned
inside `widgets/camera_capture_view.dart`, not in a data source. This is a
conscious exception: a live camera preview has to bind to a widget's
render surface and react to widget/app lifecycle (pause/resume,
dispose), which makes it a view-layer resource in Flutter's own idiom —
the same way a `TextEditingController` or `AnimationController` is owned
by the widget that renders it, not by a repository. Everything the camera
*produces* (the captured `XFile`) is handed off immediately to the
provider → repository → data source pipeline like any other input; no
business logic lives in the widget.

## Material 3

`core/app_theme.dart` builds light + dark `ThemeData` via
`ColorScheme.fromSeed`, `useMaterial3: true`. Screens use Material 3
components (`NavigationBar`, `FilledButton`, `Card`, `SegmentedButton`
where relevant) rather than Material 2 equivalents.

## Conventions

- Data sources and repositories take their dependencies via constructor
  parameters — no global lookup. `main.dart` is the single place that
  wires concrete instances together.
- Repository methods return **typed outcomes** (small enums/classes like
  `AttendanceOutcome`), never throw for expected failure states (no face
  detected, mismatch, no location). Exceptions are reserved for genuine
  unexpected errors (DB I/O failure, etc.) and are caught at the provider
  boundary.
- IDs are UUIDs (`uuid` package), not autoincrement ints — keeps
  `Staff.id` stable if sync to a backend is ever added later.
- Timestamps are stored as `millisecondsSinceEpoch` (UTC) in SQLite,
  converted to `DateTime` in models.
