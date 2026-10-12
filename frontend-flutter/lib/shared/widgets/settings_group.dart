import 'package:flutter/material.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';

/// Minimalist grouped settings container.
/// Replaces heavy, bulky standalone cards with an elegant, cohesive grouped section.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    this.title,
    this.icon,
    this.trailing,
    this.description,
    required this.children,
    this.padding = SpacingTokens.cardPadding,
  });

  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final String? description;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: semantic.actionPrimary),
                      const SizedBox(width: SpacingTokens.sm),
                    ],
                    Text(
                      title!,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: semantic.textPrimary,
                      ),
                    ),
                  ],
                ),
                ?trailing,
              ],
            ),
          ),
          if (description != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: SpacingTokens.xs),
              child: Text(
                description!,
                style: textTheme.labelSmall?.copyWith(color: semantic.textMuted),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.xs),
        ],
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ShapeTokens.borderRadiusMd,
            border: Border.all(
              color: semantic.outlineVariant,
              width: ShapeTokens.borderWidthHairline,
            ),
          ),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ],
    );
  }
}
