import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // The Sacred (Scripture)
  static TextStyle get scripture => GoogleFonts.lora(
    fontSize: 22,
    height: 1.8,
    color: AppColors.secondaryFixed,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get headline => GoogleFonts.lora(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // The Disciplined (UI)
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: AppColors.primary,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.outline,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: AppColors.outline,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.onSurfaceVariant.withOpacity(0.8),
  );

  static TextStyle get displayLarge => GoogleFonts.lora(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 4.0,
    color: AppColors.primary,
  );

  static TextStyle get displayMedium => GoogleFonts.lora(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle get displaySmall => GoogleFonts.lora(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle get headlineMedium => GoogleFonts.lora(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );
}
