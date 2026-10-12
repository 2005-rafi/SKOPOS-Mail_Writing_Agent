import 'package:flutter/material.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';

/// Themed divider with centralized thickness and spacing.
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.height = SpacingTokens.lg,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Divider(
      height: height,
      thickness: ShapeTokens.borderWidthHairline,
      color: semantic.outlineVariant,
    );
  }
}
