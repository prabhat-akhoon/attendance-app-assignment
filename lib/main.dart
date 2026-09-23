import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'data_sources/device/face_detector_data_source.dart';
import 'data_sources/device/face_embedding_data_source.dart';
import 'data_sources/device/location_data_source.dart';
import 'data_sources/device/selfie_storage_data_source.dart';
import 'data_sources/local/app_database.dart';
import 'data_sources/local/attendance_local_data_source.dart';
import 'data_sources/local/auth_local_data_source.dart';
import 'data_sources/local/face_embedding_local_data_source.dart';
import 'data_sources/local/staff_local_data_source.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/staff_provider.dart';
import 'repositories/attendance_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/face_enrollment_repository.dart';
import 'repositories/staff_repository.dart';
import 'screens/app_root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AttendanceAppBootstrap());
}

/// Opens the database, wires the dependency graph (data sources →
/// repositories → providers) once, then hands off to [AttendanceApp].
/// This is the single place concrete instances are constructed — every
/// class below it takes its dependencies via constructor injection.
class AttendanceAppBootstrap extends StatefulWidget {
  const AttendanceAppBootstrap({super.key});

  @override
  State<AttendanceAppBootstrap> createState() =>
      _AttendanceAppBootstrapState();
}

class _AttendanceAppBootstrapState extends State<AttendanceAppBootstrap> {
  late final Future<Widget> _appFuture;

  @override
  void initState() {
    super.initState();
    _appFuture = _buildApp();
  }

  Future<Widget> _buildApp() async {
    final db = await AppDatabase.instance.database;

    final authLocalDataSource = AuthLocalDataSource(db);
    final staffLocalDataSource = StaffLocalDataSource(db);
    final faceEmbeddingLocalDataSource = FaceEmbeddingLocalDataSource(db);
    final attendanceLocalDataSource = AttendanceLocalDataSource(db);

    final faceDetectorDataSource = FaceDetectorDataSource();
    final faceEmbeddingDataSource = FaceEmbeddingDataSource();
    final locationDataSource = LocationDataSource();
    final selfieStorageDataSource = SelfieStorageDataSource();

    final authRepository = AuthRepository(authLocalDataSource);
    final staffRepository =
        StaffRepository(staffLocalDataSource, authLocalDataSource);
    final faceEnrollmentRepository = FaceEnrollmentRepository(
      faceDetectorDataSource,
      faceEmbeddingDataSource,
      faceEmbeddingLocalDataSource,
      staffLocalDataSource,
    );
    final attendanceRepository = AttendanceRepository(
      faceDetectorDataSource,
      faceEmbeddingDataSource,
      faceEmbeddingLocalDataSource,
      locationDataSource,
      selfieStorageDataSource,
      attendanceLocalDataSource,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => StaffProvider(staffRepository)),
        ChangeNotifierProvider(
          create: (_) => EnrollmentProvider(faceEnrollmentRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(attendanceRepository),
        ),
      ],
      child: const AttendanceApp(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _appFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AppRoot(),
    );
  }
}
