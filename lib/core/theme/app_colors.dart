import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode - The Illuminated Codex
  static const Color primary = Color(0xFFE6C364);
  static const Color primaryContainer = Color(0xFFC9A84C);
  static const Color onPrimary = Color(0xFF3D2E00);
  static const Color onPrimaryFixed = Color(0xFF241A00);
  
  static const Color surfaceDim = Color(0xFF061423);
  static const Color surface = Color(0xFF061423);
  static const Color surfaceContainerLow = Color(0xFF0F1C2C);
  static const Color surfaceContainer = Color(0xFF132030);
  static const Color surfaceContainerHigh = Color(0xFF1E2B3B);
  static const Color surfaceContainerHighest = Color(0xFF283646);
  static const Color surfaceMedium = Color(0xFF1E2B3B); 
  
  static const Color onSurface = Color(0xFFD6E4F9);
  static const Color onSurfaceVariant = Color(0xFFD0C5B2);
  
  static const Color secondaryFixed = Color(0xFFEAE2CB);
  static const Color onSecondaryContainer = Color(0xFFBCB5A0);
  
  static const Color outline = Color(0xFF99907E);
  static const Color outlineVariant = Color(0xFF4D4637);
  
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  
  static const Color success = Color(0xFF4CAF82); // From original spec
  static const Color warning = Color(0xFFF0A500); // From original spec
  static const Color danger = Color(0xFFE05252);  // From original spec

  // Gradients
  static const Gradient goldGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    transform: GradientRotation(2.35619), // 135 degrees
  );
}
