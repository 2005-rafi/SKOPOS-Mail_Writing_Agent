import 'package:flutter/material.dart';
import 'spacing_tokens.dart';

/// Centralized component dimension and padding tokens.
abstract class ComponentTokens {
  // Buttons
  static const double buttonHeight = 44.0;
  static const double buttonHeightSm = 36.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: SpacingTokens.lg,
    vertical: SpacingTokens.sm,
  );
  static const EdgeInsets buttonPaddingSm = EdgeInsets.symmetric(
    horizontal: SpacingTokens.md,
    vertical: SpacingTokens.xs,
  );

  // Inputs
  static const double inputHeight = 48.0;
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: SpacingTokens.md,
    vertical: SpacingTokens.md,
  );

  // Icons
  static const double iconSizeXs = 14.0;
  static const double iconSizeSm = 18.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 24.0;
  static const double iconSizeXl = 32.0;

  // Badges
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: SpacingTokens.sm,
    vertical: SpacingTokens.xs,
  );
}
