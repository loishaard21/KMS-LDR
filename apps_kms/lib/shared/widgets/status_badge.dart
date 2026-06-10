import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    final normalized = status.toLowerCase();

    if (normalized == 'active' || normalized == 'pendaftaran dibuka' || normalized == 'confirmed' || normalized == 'aktif') {
      bg = const Color(0xFFDCFCE7); // Light Green
      text = const Color(0xFF15803D); // Dark Green
    } else if (normalized == 'inactive' || normalized == 'pendaftaran ditutup' || normalized == 'penuh' || normalized == 'tidak aktif') {
      bg = const Color(0xFFFEE2E2); // Light Red
      text = const Color(0xFFB91C1C); // Dark Red
    } else if (normalized == 'super admin' || normalized == 'superadmin') {
      bg = const Color(0xFFF3E8FF); // Light Purple
      text = const Color(0xFF7E22CE); // Dark Purple
    } else if (normalized == 'operator') {
      bg = const Color(0xFFEEF4FF); // Light Blue
      text = const Color(0xFF0052CC); // Dark Blue
    } else if (normalized == 'certificate issued' || normalized == 'attended') {
      bg = const Color(0xFFE0F2FE); // Light Teal
      text = const Color(0xFF0369A1); // Dark Teal
    } else {
      bg = const Color(0xFFF1F5F9); // Light Grey
      text = const Color(0xFF475569); // Dark Grey
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
