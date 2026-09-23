import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../repositories/attendance_repository.dart';
import '../../widgets/camera_capture_view.dart';
import '../../widgets/result_banner.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String staffId;

  const MarkAttendanceScreen({super.key, required this.staffId});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  Future<void> _handleCapture(String path) async {
    final provider = context.read<AttendanceProvider>();
    final result = await provider.markAttendance(
      staffId: widget.staffId,
      selfieImagePath: path,
    );
    if (result.isSuccess && mounted) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _titleFor(AttendanceOutcome outcome) {
    switch (outcome) {
      case AttendanceOutcome.success:
        return 'Attendance marked';
      case AttendanceOutcome.noFaceDetected:
        return 'No face detected';
      case AttendanceOutcome.multipleFacesDetected:
        return 'More than one face detected';
      case AttendanceOutcome.faceNotEnrolled:
        return 'Your face has not been enrolled yet';
      case AttendanceOutcome.faceMismatch:
        return 'Face does not match enrolled photo';
      case AttendanceOutcome.locationUnavailable:
        return 'Could not get your location';
      case AttendanceOutcome.imageUnreadable:
        return 'Could not process that photo';
    }
  }

  String? _subtitleFor(MarkAttendanceResult result) {
    switch (result.outcome) {
      case AttendanceOutcome.faceNotEnrolled:
        return 'Ask an admin to enrol your face first.';
      case AttendanceOutcome.faceMismatch:
        final score = result.matchScore;
        return score == null
            ? 'Try again with better lighting.'
            : 'Match confidence ${(score * 100).toStringAsFixed(0)}% — below the required threshold.';
      case AttendanceOutcome.locationUnavailable:
        return 'Enable location services and grant permission, then retry.';
      case AttendanceOutcome.success:
        return 'Timestamp, selfie and location have been recorded.';
      default:
        return 'Please retry with a clear, well-lit selfie.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final result = provider.lastResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Mark attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (result != null) ...[
              ResultBanner(
                success: result.isSuccess,
                title: _titleFor(result.outcome),
                subtitle: _subtitleFor(result),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: provider.isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : CameraCaptureView(
                      instructions: 'Look at the camera to mark your attendance',
                      onCaptured: (file) => _handleCapture(file.path),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
