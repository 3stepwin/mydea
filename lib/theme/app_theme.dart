import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core brand colors
  static const Color primaryColor = Color(0xFF00CCFF); // Cyan
  static const Color secondaryColor = Color(0xFF9933FF); // Purple
  static const Color tertiaryColor = Color(0xFF00FFCC); // Teal
  static const Color darkBackground = Color(0xFF0A0C1B); // Dark navy
  static const Color darkerBackground = Color(0xFF060914); // Even darker navy
  static const Color lightText = Color(0xFFF1F3FF); // Nearly white with slight blue tint
  static const Color secondaryText = Color(0xFFB4B9D6); // Light gray with blue tint

  // Gradients
  // Note: Gradients below are defined as Gradient objects. Access colors via .colors property.
  static const LinearGradient primaryGradient = LinearGradient( // Explicitly type as LinearGradient
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient( // Explicitly type as LinearGradient
    colors: [secondaryColor, tertiaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tertiaryGradient = LinearGradient( // Explicitly type as LinearGradient
    colors: [tertiaryColor, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Define missing gradients found in usage
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [darkBackground, darkerBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryButtonGradient = primaryGradient; // Map to existing
  static const LinearGradient secondaryButtonGradient = secondaryGradient; // Map to existing


  // Shadow for glow effects
  static List<BoxShadow> glowShadow({Color? color, double intensity = 1.0}) {
    final Color shadowColor = color ?? primaryColor;
    return [
      BoxShadow(
        color: shadowColor.withAlpha(((0.4 * intensity) * 255).round().clamp(0, 255)), // Use withAlpha
        blurRadius: 15 * intensity,
        spreadRadius: 5 * intensity,
      ),
      BoxShadow(
        color: shadowColor.withAlpha(((0.2 * intensity) * 255).round().clamp(0, 255)), // Use withAlpha
        blurRadius: 30 * intensity,
        spreadRadius: 10 * intensity,
      ),
    ];
  }

  // Text styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightText,
      );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightText,
      );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
        fontSize: 16,
        color: lightText,
      );

  static TextStyle get subtitleStyle => GoogleFonts.poppins(
        fontSize: 14,
        color: secondaryText,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightText,
      );

  // Theme data for MaterialApp
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      textTheme: TextTheme(
        displayLarge: headingStyle,
        displayMedium: subheadingStyle,
        bodyLarge: bodyStyle,
        bodyMedium: subtitleStyle,
        labelLarge: buttonTextStyle,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        background: darkBackground,
        surface: darkerBackground,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkerBackground.withAlpha((0.5 * 255).round()), // Use withAlpha
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: lightText.withAlpha((0.1 * 255).round()), // Use withAlpha
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: lightText.withAlpha((0.1 * 255).round()), // Use withAlpha
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.poppins(color: secondaryText),
        hintStyle: GoogleFonts.poppins(color: secondaryText.withAlpha((0.7 * 255).round())), // Use withAlpha
      ),
    );
  }
}