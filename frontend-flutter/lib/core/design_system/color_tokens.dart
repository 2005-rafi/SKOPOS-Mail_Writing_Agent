import 'package:flutter/material.dart';

/// Centralized raw and semantic color palette for SKOPOS.
/// Based strictly on Moon Garden (#E7F2E4) and Crimson Orchid (#732255).
abstract class ColorTokens {
  // Brand Anchors
  static const Color moonGarden = Color(0xFFE7F2E4);
  static const Color crimsonOrchid = Color(0xFF732255);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF5F9F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFEBF3E8);
  static const Color lightSurfaceContainerHigh = Color(0xFFE0ECE0);
  static const Color lightSurfaceContainerHighest = Color(0xFFD4E2D3);

  static const Color lightTextPrimary = Color(0xFF1E141B);
  static const Color lightTextSecondary = Color(0xFF4C3C45);
  static const Color lightTextMuted = Color(0xFF76636E);

  static const Color lightActionPrimary = crimsonOrchid;
  static const Color lightOnActionPrimary = Color(0xFFFFFFFF);
  static const Color lightActionSecondary = Color(0xFF5A1A43);
  static const Color lightOnActionSecondary = Color(0xFFFFFFFF);

  static const Color lightOutline = Color(0xFFC7D5C5);
  static const Color lightOutlineVariant = Color(0xFFDAE4D8);
  static const Color lightFocusRing = crimsonOrchid;

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF120E11);
  static const Color darkSurface = Color(0xFF1A1419);
  static const Color darkSurfaceContainer = Color(0xFF231C21);
  static const Color darkSurfaceContainerHigh = Color(0xFF2D232B);
  static const Color darkSurfaceContainerHighest = Color(0xFF382C36);

  static const Color darkTextPrimary = Color(0xFFF5EFF3);
  static const Color darkTextSecondary = Color(0xFFCCBFC7);
  static const Color darkTextMuted = Color(0xFF9D8D97);

  static const Color darkActionPrimary = Color(0xFFC95497);
  static const Color darkOnActionPrimary = Color(0xFF140810);
  static const Color darkActionSecondary = Color(0xFFB54385);
  static const Color darkOnActionSecondary = Color(0xFFFFFFFF);

  static const Color darkOutline = Color(0xFF3E323A);
  static const Color darkOutlineVariant = Color(0xFF2C2229);
  static const Color darkFocusRing = Color(0xFFE89DC8);

  // Status Colors (Accessible for Light & Dark)
  static const Color statusSuccessLight = Color(0xFF237829);
  static const Color statusSuccessDark = Color(0xFF63BA68);

  static const Color statusWarningLight = Color(0xFFC95B00);
  static const Color statusWarningDark = Color(0xFFFFA024);

  static const Color statusErrorLight = Color(0xFFBF2626);
  static const Color statusErrorDark = Color(0xFFF25A57);

  static const Color statusInfoLight = Color(0xFF0073B7);
  static const Color statusInfoDark = Color(0xFF3EA3E0);
}
