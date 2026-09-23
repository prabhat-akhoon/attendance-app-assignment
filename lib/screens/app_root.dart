import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import 'admin/staff_list_screen.dart';
import 'auth/login_screen.dart';
import 'staff/staff_home_screen.dart';

/// Swaps between the login screen and the role-appropriate home screen
/// based on [AuthProvider.currentUser]. Kept deliberately simple (no named
/// routes) since the two role flows never need to link to each other.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) return const LoginScreen();
    if (user.role == UserRole.admin) return const StaffListScreen();
    return const StaffHomeScreen();
  }
}
