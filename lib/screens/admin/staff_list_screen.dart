import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/staff_list_tile.dart';
import 'add_staff_screen.dart';
import 'staff_profile_screen.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<StaffProvider>().loadStaff(),
        child: staffProvider.isLoading && staffProvider.staffList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : staffProvider.staffList.isEmpty
                ? ListView(
                    children: const [
                      EmptyState(
                        icon: Icons.groups_outlined,
                        message: 'No staff yet.\nTap + to add your first staff member.',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: staffProvider.staffList.length,
                    itemBuilder: (context, index) {
                      final staff = staffProvider.staffList[index];
                      return StaffListTile(
                        staff: staff,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StaffProfileScreen(staffId: staff.id),
                            ),
                          );
                          if (context.mounted) {
                            context.read<StaffProvider>().loadStaff();
                          }
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddStaffScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add staff'),
      ),
    );
  }
}
