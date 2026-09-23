import 'package:flutter/material.dart';

class ResultBanner extends StatelessWidget {
  final bool success;
  final String title;
  final String? subtitle;

  const ResultBanner({
    super.key,
    required this.success,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = success ? scheme.primaryContainer : scheme.errorContainer;
    final fg = success ? scheme.onPrimaryContainer : scheme.onErrorContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(success ? Icons.check_circle : Icons.error, color: fg),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: TextStyle(color: fg)),
          ],
        ],
      ),
    );
  }
}
