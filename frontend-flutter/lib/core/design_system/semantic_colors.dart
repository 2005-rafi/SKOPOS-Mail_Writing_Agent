import 'package:flutter/material.dart';
import 'color_tokens.dart';

/// Semantic colors accessible through `Theme.of(context).extension<SemanticColors>()!`
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.actionPrimary,
    required this.onActionPrimary,
    required this.actionSecondary,
    required this.onActionSecondary,
    required this.outline,
    required this.outlineVariant,
    required this.focusRing,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfo,
  });

  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color actionPrimary;
  final Color onActionPrimary;
  final Color actionSecondary;
  final Color onActionSecondary;

  final Color outline;
  final Color outlineVariant;
  final Color focusRing;

  final Color statusSuccess;
  final Color statusWarning;
  final Color statusError;
  final Color statusInfo;

  /// Light semantic palette derived from ColorTokens
  static const SemanticColors light = SemanticColors(
    surfaceContainer: ColorTokens.lightSurfaceContainer,
    surfaceContainerHigh: ColorTokens.lightSurfaceContainerHigh,
    surfaceContainerHighest: ColorTokens.lightSurfaceContainerHighest,
    textPrimary: ColorTokens.lightTextPrimary,
    textSecondary: ColorTokens.lightTextSecondary,
    textMuted: ColorTokens.lightTextMuted,
    actionPrimary: ColorTokens.lightActionPrimary,
    onActionPrimary: ColorTokens.lightOnActionPrimary,
    actionSecondary: ColorTokens.lightActionSecondary,
    onActionSecondary: ColorTokens.lightOnActionSecondary,
    outline: ColorTokens.lightOutline,
    outlineVariant: ColorTokens.lightOutlineVariant,
    focusRing: ColorTokens.lightFocusRing,
    statusSuccess: ColorTokens.statusSuccessLight,
    statusWarning: ColorTokens.statusWarningLight,
    statusError: ColorTokens.statusErrorLight,
    statusInfo: ColorTokens.statusInfoLight,
  );

  /// Dark semantic palette derived from ColorTokens
  static const SemanticColors dark = SemanticColors(
    surfaceContainer: ColorTokens.darkSurfaceContainer,
    surfaceContainerHigh: ColorTokens.darkSurfaceContainerHigh,
    surfaceContainerHighest: ColorTokens.darkSurfaceContainerHighest,
    textPrimary: ColorTokens.darkTextPrimary,
    textSecondary: ColorTokens.darkTextSecondary,
    textMuted: ColorTokens.darkTextMuted,
    actionPrimary: ColorTokens.darkActionPrimary,
    onActionPrimary: ColorTokens.darkOnActionPrimary,
    actionSecondary: ColorTokens.darkActionSecondary,
    onActionSecondary: ColorTokens.darkOnActionSecondary,
    outline: ColorTokens.darkOutline,
    outlineVariant: ColorTokens.darkOutlineVariant,
    focusRing: ColorTokens.darkFocusRing,
    statusSuccess: ColorTokens.statusSuccessDark,
    statusWarning: ColorTokens.statusWarningDark,
    statusError: ColorTokens.statusErrorDark,
    statusInfo: ColorTokens.statusInfoDark,
  );

  @override
  ThemeExtension<SemanticColors> copyWith({
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? actionPrimary,
    Color? onActionPrimary,
    Color? actionSecondary,
    Color? onActionSecondary,
    Color? outline,
    Color? outlineVariant,
    Color? focusRing,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusError,
    Color? statusInfo,
  }) {
    return SemanticColors(
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      onActionPrimary: onActionPrimary ?? this.onActionPrimary,
      actionSecondary: actionSecondary ?? this.actionSecondary,
      onActionSecondary: onActionSecondary ?? this.onActionSecondary,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      focusRing: focusRing ?? this.focusRing,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
      statusInfo: statusInfo ?? this.statusInfo,
    );
  }

  @override
  ThemeExtension<SemanticColors> lerp(
    covariant ThemeExtension<SemanticColors>? other,
    double t,
  ) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      onActionPrimary: Color.lerp(onActionPrimary, other.onActionPrimary, t)!,
      actionSecondary: Color.lerp(actionSecondary, other.actionSecondary, t)!,
      onActionSecondary: Color.lerp(onActionSecondary, other.onActionSecondary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
    );
  }
}

/// Convenience extension on BuildContext to quickly access SemanticColors
extension SemanticColorsBuildContext on BuildContext {
  SemanticColors get semanticColors {
    return Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
  }
}
