import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/staff.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/attendance_record_tile.dart';
import '../../widgets/empty_state.dart';
import 'enroll_face_screen.dart';

class StaffProfileScreen extends StatefulWidget {
  final String staffId;

  const StaffProfileScreen({super.key, required this.staffId});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  Staff? _staff;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final staff = await context.read<StaffProvider>().refreshStaff(widget.staffId);
    if (!mounted) return;
    await context.read<AttendanceProvider>().loadHistory(widget.staffId);
    if (mounted) {
      setState(() {
        _staff = staff;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final staff = _staff;

    return Scaffold(
      appBar: AppBar(title: Text(staff?.name ?? 'Staff profile')),
      body: _isLoading || staff == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(staff.name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text('Employee ID: ${staff.employeeId}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                staff.isFaceEnrolled
                                    ? Icons.check_circle
                                    : Icons.face_retouching_off,
                                color: staff.isFaceEnrolled ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(staff.isFaceEnrolled ? 'Face enrolled' : 'Face not enrolled'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EnrollFaceScreen(staffId: staff.id),
                                ),
                              );
                              if (context.mounted) _load();
                            },
                            icon: const Icon(Icons.face),
                            label: Text(staff.isFaceEnrolled ? 'Re-enrol face' : 'Enrol face'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Attendance history', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (attendanceProvider.history.isEmpty)
                    const EmptyState(
                      icon: Icons.event_busy,
                      message: 'No attendance recorded yet',
                    )
                  else
                    ...attendanceProvider.history.map((r) => AttendanceRecordTile(record: r)),
                ],
              ),
            ),
    );
  }
}
