import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_record.dart';

class AttendanceRecordTile extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final formatted =
        DateFormat('EEE, d MMM yyyy • h:mm a').format(record.timestamp);
    final file = File(record.selfiePath);

    return Card(
      child: ListTile(
        onTap: () => _showDetails(context),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: file.existsSync()
              ? Image.file(file, width: 48, height: 48, fit: BoxFit.cover)
              : Container(
                  width: 48,
                  height: 48,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person),
                ),
        ),
        title: Text(formatted),
        subtitle: Text(
          record.address ??
              '${record.latitude.toStringAsFixed(5)}, ${record.longitude.toStringAsFixed(5)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${(record.matchScore * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final formatted =
        DateFormat('EEE, d MMM yyyy • h:mm a').format(record.timestamp);
    final file = File(record.selfiePath);
    final coordinates =
        '${record.latitude.toStringAsFixed(5)}, ${record.longitude.toStringAsFixed(5)}';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: file.existsSync()
                        ? Image.file(file, width: 120, height: 120, fit: BoxFit.cover)
                        : Container(
                            width: 120,
                            height: 120,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.person, size: 48),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                _DetailRow(icon: Icons.schedule, label: 'Timestamp', value: formatted),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: record.address ?? coordinates,
                ),
                if (record.address != null) ...[
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.explore_outlined,
                    label: 'Coordinates',
                    value: coordinates,
                  ),
                ],
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.verified_outlined,
                  label: 'Match confidence',
                  value: '${(record.matchScore * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
