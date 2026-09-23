import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/enrollment_provider.dart';
import '../../repositories/face_enrollment_repository.dart';
import '../../widgets/camera_capture_view.dart';
import '../../widgets/result_banner.dart';

class EnrollFaceScreen extends StatefulWidget {
  final String staffId;

  const EnrollFaceScreen({super.key, required this.staffId});

  @override
  State<EnrollFaceScreen> createState() => _EnrollFaceScreenState();
}

class _EnrollFaceScreenState extends State<EnrollFaceScreen> {
  Future<void> _handleCapture(String path) async {
    final provider = context.read<EnrollmentProvider>();
    final outcome =
        await provider.enroll(staffId: widget.staffId, imagePath: path);
    if (outcome == FaceEnrollmentOutcome.success && mounted) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _messageFor(FaceEnrollmentOutcome outcome) {
    switch (outcome) {
      case FaceEnrollmentOutcome.success:
        return 'Face enrolled successfully';
      case FaceEnrollmentOutcome.noFaceDetected:
        return 'No face detected — try again with better lighting';
      case FaceEnrollmentOutcome.multipleFacesDetected:
        return 'More than one face detected — make sure only the staff member is in frame';
      case FaceEnrollmentOutcome.imageUnreadable:
        return 'Could not process that photo — please retry';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnrollmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Enrol face')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (provider.lastOutcome != null) ...[
              ResultBanner(
                success: provider.lastOutcome == FaceEnrollmentOutcome.success,
                title: _messageFor(provider.lastOutcome!),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: provider.isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : CameraCaptureView(
                      instructions:
                          'Capture a clear, front-facing selfie of the staff member',
                      onCaptured: (file) => _handleCapture(file.path),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
