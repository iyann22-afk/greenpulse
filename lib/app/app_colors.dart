import 'package:flutter/material.dart';

/// GREENPULSE Brand Color Tokens
class AppColors {
  AppColors._();

  // Primary palette
  static const Color forestGreen = Color(0xFF143D2B);
  static const Color pulseGreen = Color(0xFF27AE60);
  static const Color freshLime = Color(0xFFB8ED78);
  static const Color softOrganic = Color(0xFFF3F7F0);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Status colors
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color criticalRed = Color(0xFFEF4444);
  static const Color normalGreen = Color(0xFF27AE60);

  // Text
  static const Color mutedText = Color(0xFF718078);
  static const Color darkText = Color(0xFF1A2E22);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF143D2B),
      Color(0xFF1E5C40),
      Color(0xFF27AE60),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF27AE60),
      Color(0xFF1E8449),
    ],
  );

  static const LinearGradient humidityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1565C0),
      Color(0xFF1976D2),
      Color(0xFF42A5F5),
    ],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF3F7F0),
      Color(0xFFEBF3E8),
    ],
  );
}
