import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_tokens.dart';
import 'component_tokens.dart';
import 'semantic_colors.dart';
import 'shape_tokens.dart';
import 'spacing_tokens.dart';
import 'typography_tokens.dart';

/// Centralized ThemeData provider for SKOPOS.
abstract class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = TypographyTokens.createTextTheme(
      ColorTokens.lightTextPrimary,
      ColorTokens.lightTextSecondary,
    );

    final colorScheme = const ColorScheme.light(
      primary: ColorTokens.lightActionPrimary,
      onPrimary: ColorTokens.lightOnActionPrimary,
      secondary: ColorTokens.lightActionSecondary,
      onSecondary: ColorTokens.lightOnActionSecondary,
      surface: ColorTokens.lightSurface,
      onSurface: ColorTokens.lightTextPrimary,
      error: ColorTokens.statusErrorLight,
      onError: ColorTokens.lightOnActionPrimary,
      outline: ColorTokens.lightOutline,
      outlineVariant: ColorTokens.lightOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorTokens.lightBackground,
      textTheme: textTheme,
      extensions: const [SemanticColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorTokens.lightSurface,
        foregroundColor: ColorTokens.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: ColorTokens.lightSurface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorTokens.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          side: const BorderSide(
            color: ColorTokens.lightOutline,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorTokens.lightSurface,
        contentPadding: ComponentTokens.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.lightOutline,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.lightOutline,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.lightFocusRing,
            width: ShapeTokens.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.statusErrorLight,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ColorTokens.lightTextMuted,
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: ColorTokens.lightTextSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ColorTokens.lightOutlineVariant,
        thickness: ShapeTokens.borderWidthHairline,
        space: SpacingTokens.lg,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = TypographyTokens.createTextTheme(
      ColorTokens.darkTextPrimary,
      ColorTokens.darkTextSecondary,
    );

    final colorScheme = const ColorScheme.dark(
      primary: ColorTokens.darkActionPrimary,
      onPrimary: ColorTokens.darkOnActionPrimary,
      secondary: ColorTokens.darkActionSecondary,
      onSecondary: ColorTokens.darkOnActionSecondary,
      surface: ColorTokens.darkSurface,
      onSurface: ColorTokens.darkTextPrimary,
      error: ColorTokens.statusErrorDark,
      onError: ColorTokens.darkOnActionPrimary,
      outline: ColorTokens.darkOutline,
      outlineVariant: ColorTokens.darkOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorTokens.darkBackground,
      textTheme: textTheme,
      extensions: const [SemanticColors.dark],
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorTokens.darkSurface,
        foregroundColor: ColorTokens.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: ColorTokens.darkSurface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorTokens.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          side: const BorderSide(
            color: ColorTokens.darkOutline,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorTokens.darkSurfaceContainer,
        contentPadding: ComponentTokens.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.darkOutline,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.darkOutline,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.darkFocusRing,
            width: ShapeTokens.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          borderSide: const BorderSide(
            color: ColorTokens.statusErrorDark,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ColorTokens.darkTextMuted,
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: ColorTokens.darkTextSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ColorTokens.darkOutlineVariant,
        thickness: ShapeTokens.borderWidthHairline,
        space: SpacingTokens.lg,
      ),
    );
  }
}
