import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Base DM Sans TextStyle
  static TextStyle get _baseDMSans => GoogleFonts.dmSans();

  // Heading Styles
  static TextStyle get heading1 => _baseDMSans.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get heading2 => _baseDMSans.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get heading3 => _baseDMSans.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text Styles
  static TextStyle get bodyLarge => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Button Styles
  static TextStyle get buttonLarge => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonMedium => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // App Bar Style
  static TextStyle get appBarTitle => _baseDMSans.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // Counter/Display Styles
  static TextStyle get counterLarge => _baseDMSans.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
    height: 1.1,
  );

  // Caption/Subtitle Styles
  static TextStyle get caption => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
