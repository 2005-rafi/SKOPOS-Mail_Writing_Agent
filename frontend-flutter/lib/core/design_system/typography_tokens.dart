import 'package:flutter/material.dart';

/// Centralized typography styles and TextTheme factory.
abstract class TypographyTokens {
  // Font Sizes
  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 22.0;
  static const double fontSizeXxl = 28.0;

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Build centralized TextTheme
  static TextTheme createTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: fontSizeXxl,
        fontWeight: bold,
        color: primaryTextColor,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXl,
        fontWeight: bold,
        color: primaryTextColor,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      // Headlines
      headlineSmall: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: semiBold,
        color: primaryTextColor,
        letterSpacing: -0.2,
        height: 1.35,
      ),
      // Titles
      titleMedium: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: semiBold,
        color: primaryTextColor,
        letterSpacing: 0.0,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: fontSizeBase,
        fontWeight: medium,
        color: primaryTextColor,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: regular,
        color: primaryTextColor,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeBase,
        fontWeight: regular,
        color: primaryTextColor,
        letterSpacing: 0.15,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: regular,
        color: secondaryTextColor,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      // Labels
      labelLarge: TextStyle(
        fontSize: fontSizeBase,
        fontWeight: medium,
        color: primaryTextColor,
        letterSpacing: 0.1,
        height: 1.3,
      ),
      labelMedium: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: medium,
        color: secondaryTextColor,
        letterSpacing: 0.2,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        fontSize: fontSizeXs,
        fontWeight: medium,
        color: secondaryTextColor,
        letterSpacing: 0.3,
        height: 1.2,
      ),
    );
  }
}
