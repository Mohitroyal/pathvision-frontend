// lib/theme/jarvis_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'jarvis_colors.dart';

class JarvisTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        surface: bgTertiary,
        surfaceContainer: bgQuaternary,
        error: dangerColor,
        onPrimary: bgPrimary,
        onSurface: textPrimary,
        onSurfaceVariant: textDim,
      ),
      
      // Text Themes
      textTheme: TextTheme(
        // Headings
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: 1.5,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 1,
        ),
        
        // Titles
        titleLarge: GoogleFonts.orbitron(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: gold,
          letterSpacing: 1.5,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: gold,
          letterSpacing: 0.5,
        ),
        
        // Body
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMid,
        ),
        bodySmall: GoogleFonts.rajdhani(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textDim,
        ),
        
        // Label
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: gold,
          letterSpacing: 1.2,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: textDim,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          fontWeight: FontWeight.w400,
          color: textDim,
          letterSpacing: 0.3,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: bgPrimary.withOpacity(0.97),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: gold,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: gold),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: bgTertiary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: goldLine, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: gold,
        size: 24,
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(gold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgQuaternary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: goldLine, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: goldLine, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: gold, width: 1),
        ),
        labelStyle: GoogleFonts.rajdhani(color: textDim),
        hintStyle: GoogleFonts.rajdhani(color: textDim),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgTertiary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
    );
  }
}

// Export spacing constants
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// Export border radius
class BorderValues {
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 12;
  static const double xl = 24;
}

// Shadow definitions
class JarvisShadows {
  static List<BoxShadow> goldGlowShadow = [
    BoxShadow(
      color: goldGlow,
      blurRadius: 12,
      spreadRadius: 2,
      offset: Offset.zero,
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> smallShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];
}
