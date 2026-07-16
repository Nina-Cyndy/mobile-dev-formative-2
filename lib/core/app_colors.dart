import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color aluBlue = Color(0xFF0B2545);
  static const Color aluBlueLight = Color(0xFF13315C);
  static const Color aluGold = Color(0xFFF5A623);

  // Semantic
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFE0453B);
  static const Color warning = Color(0xFFF5A623);
  static const Color info = Color(0xFF3E7BFA);

  // Neutrals
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E8EF);
  static const Color textPrimary = Color(0xFF16213E);
  static const Color textSecondary = Color(0xFF6B7280);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aluBlue, aluBlueLight],
  );

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return success;
      case 'rejected':
        return danger;
      default:
        return warning;
    }
  }
}
