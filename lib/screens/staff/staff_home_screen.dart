import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/attendance_record_tile.dart';
import '../../widgets/empty_state.dart';
import 'mark_attendance_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  void _loadHistory() {
    final staffId = context.read<AuthProvider>().currentUser?.staffId;
    if (staffId != null) {
      context.read<AttendanceProvider>().loadHistory(staffId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final staffId = auth.currentUser?.staffId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: staffId == null
          ? const EmptyState(
              icon: Icons.error_outline,
              message: 'No staff profile linked to this account',
            )
          : RefreshIndicator(
              onRefresh: () async => _loadHistory(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MarkAttendanceScreen(staffId: staffId),
                        ),
                      );
                      if (context.mounted) _loadHistory();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Mark attendance'),
                  ),
                  const SizedBox(height: 24),
                  Text('History', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (attendanceProvider.isLoadingHistory)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (attendanceProvider.history.isEmpty)
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
