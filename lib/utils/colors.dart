import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDarkBlue = Color(0xFF1B365D);
  static const Color secondaryDarkBlue = Color(0xFF2E5984);
  static const Color primaryOrange = Colors.blue;
  static const Color secondaryWhite = Colors.white;
  static const Color secondaryGrey = Colors.grey;
  static const Color accentBlue = Colors.blue;
  static const Color accentGreen = Colors.green;
  static const Color accentAmber = Colors.blueAccent;
  static const Color lightGrey = Color(0xFFE0E0E0);

  // Additional Colors for better UI
  static const Color darkGrey = Color(0xFF374151);
  static const Color mediumGrey = Color(0xFF6B7280);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color lightOrange = Color(0xFFFED7AA);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    primaryDarkBlue,
    Color(0xFF2563EB),
  ];

  static const List<Color> orangeGradient = [primaryOrange, Color(0xFFEA580C)];
}
