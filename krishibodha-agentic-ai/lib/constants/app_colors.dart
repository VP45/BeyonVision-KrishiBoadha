import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF427662); // #427662
  static const Color primaryLight = Color(0xFFA0BAB0); // #A0BAB0

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(
    0xFFF2F3F2,
  ); // #F2F3F2 (corrected from #F2F3F200)

  // Text Colors
  static const Color textPrimary = Color(0xFF0D1814); // #0D1814
  static const Color textSecondary = Color(0xFF427662); // Same as primary dark
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White text on primary buttons

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark, // #427662
      primaryLight, // #A0BAB0
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundPrimary, // White
      backgroundSecondary, // #F2F3F2
    ],
    stops: [0.0, 1.0],
  );

  // Additional UI Colors
  static const Color buttonPrimary = primaryDark;
  static const Color buttonSecondary = primaryLight;
  static const Color appBarBackground = primaryDark;
  static const Color cardBackground = backgroundPrimary;
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1A000000);
  static const Color errorColor = Color(0xFFD32F2F); // Red for errors
  static const Color successColor = Color(0xFF4CAF50); // Green for success

  // Aliases for compatibility
  static const Color primary = primaryDark;
  static const Color success = successColor;
}
