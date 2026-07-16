import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({super.key, required this.label, required this.color, this.icon});

  factory StatusBadge.applicationStatus(String status) {
    final color = AppColors.statusColor(status);
    final icon = switch (status.toLowerCase()) {
      'accepted' => Icons.check_circle,
      'rejected' => Icons.cancel,
      _ => Icons.hourglass_top,
    };
    return StatusBadge(
      label: status[0].toUpperCase() + status.substring(1),
      color: color,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 5)],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
