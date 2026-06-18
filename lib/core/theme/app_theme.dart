import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Peblo-inspired brand palette — warm, playful, child-friendly.
abstract final class PebloColors {
  static const purple = Color(0xFF6B4EFF);
  static const purpleDark = Color(0xFF4A32D4);
  static const orange = Color(0xFFFF8A3D);
  static const orangeLight = Color(0xFFFFB347);
  static const sky = Color(0xFF4ECDC4);
  static const skyLight = Color(0xFFB8F2EF);
  static const cream = Color(0xFFFFF8F0);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D2A4A);
  static const textMuted = Color(0xFF6B6889);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE85D5D);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PebloColors.purple,
        primary: PebloColors.purple,
        secondary: PebloColors.orange,
        surface: PebloColors.cream,
      ),
      scaffoldBackgroundColor: PebloColors.cream,
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: PebloColors.textDark,
        displayColor: PebloColors.textDark,
      ),
    );
  }
}
