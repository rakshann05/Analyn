// lib/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- 🍏 iOS Style Guide Palette ---
  static const Color background = Color(0xFFFAF9F7); // Ivory White
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF013220); // Deep Emerald
  static const Color premiumAccent = Color(0xFFD4AF37); // Gold
  static const Color darkText = Color(0xFF2E2E2E);
  static const Color lightText = Color(0xFF6E6E6E);

  // --- Typography ---
  static TextTheme get textTheme {
    return TextTheme(
      // For large titles like "Our Services"
      headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
      // For card titles
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: darkText), // Semibold
      // For body text and subtitles
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: lightText),
    );
  }

  // --- Main App Theme ---
  static ThemeData get theme {
    return ThemeData(
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background, // Ivory white background
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 1.5, // Very subtle shadow
        color: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Softer corners
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: premiumAccent, // Gold for primary buttons
          foregroundColor: darkText,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), // Pill shape
          textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
