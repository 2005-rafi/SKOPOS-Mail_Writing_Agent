import 'package:flutter/material.dart';

/// Centralized animation durations and motion curves.
abstract class MotionTokens {
  // Durations
  static const Duration durationMicro = Duration(milliseconds: 120);
  static const Duration durationStandard = Duration(milliseconds: 200);
  static const Duration durationPage = Duration(milliseconds: 260);
  static const Duration durationLong = Duration(milliseconds: 350);

  // Curves
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.easeOutCubic;
  static const Curve curveAccelerate = Curves.easeInCubic;
}
