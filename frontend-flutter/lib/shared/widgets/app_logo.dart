import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';

/// Reusable brand logo widget rendering the official SKOPOS logo asset.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = ComponentTokens.iconSizeLg,
    this.borderRadius,
    this.showBorder = false,
  });

  /// The width and height of the logo in logical pixels.
  final double size;

  /// Optional custom border radius (defaults to ShapeTokens.borderRadiusSm).
  final BorderRadius? borderRadius;

  /// Whether to render a subtle brand outline around the logo.
  final bool showBorder;

  static const String assetPath = 'assets/logo/logo.png';

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final radius = borderRadius ?? ShapeTokens.borderRadiusSm;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: showBorder
            ? Border.all(
                color: semantic.actionPrimary.withValues(alpha: 0.2),
                width: ShapeTokens.borderWidthHairline,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Graceful vector fallback if asset is unavailable in test environment
            return Container(
              color: semantic.actionPrimary.withValues(alpha: 0.12),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: size * 0.7,
                color: semantic.actionPrimary,
              ),
            );
          },
        ),
      ),
    );
  }
}
