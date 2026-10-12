import 'package:flutter/material.dart';

/// Centralized elevation and shadow definitions.
abstract class ElevationTokens {
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 2.0;
  static const double level3 = 4.0;
  static const double level4 = 8.0;

  static List<BoxShadow> shadowLevel1(Color shadowColor) => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ];

  static List<BoxShadow> shadowLevel2(Color shadowColor) => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ];
}
