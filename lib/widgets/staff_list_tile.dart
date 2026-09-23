import 'package:flutter/material.dart';

import '../models/staff.dart';

class StaffListTile extends StatelessWidget {
  final Staff staff;
  final VoidCallback onTap;

  const StaffListTile({super.key, required this.staff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?'),
        ),
        title: Text(staff.name),
        subtitle: Text('ID: ${staff.employeeId}'),
        trailing: Chip(
          avatar: Icon(
            staff.isFaceEnrolled ? Icons.check_circle : Icons.face_retouching_off,
            size: 18,
            color: staff.isFaceEnrolled ? Colors.green : Colors.orange,
          ),
          label: Text(staff.isFaceEnrolled ? 'Enrolled' : 'Not enrolled'),
        ),
      ),
    );
  }
}
