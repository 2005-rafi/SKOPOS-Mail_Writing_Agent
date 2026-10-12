import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';

enum AppBadgeVariant { success, warning, error, info, neutral, brand }

/// Semantic status badge displaying an icon and text (zero emojis).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    Color bg;
    Color fg;

    switch (variant) {
      case AppBadgeVariant.success:
        bg = semantic.statusSuccess.withValues(alpha: 0.15);
        fg = semantic.statusSuccess;
        break;
      case AppBadgeVariant.warning:
        bg = semantic.statusWarning.withValues(alpha: 0.15);
        fg = semantic.statusWarning;
        break;
      case AppBadgeVariant.error:
        bg = semantic.statusError.withValues(alpha: 0.15);
        fg = semantic.statusError;
        break;
      case AppBadgeVariant.info:
        bg = semantic.statusInfo.withValues(alpha: 0.15);
        fg = semantic.statusInfo;
        break;
      case AppBadgeVariant.brand:
        bg = semantic.actionPrimary.withValues(alpha: 0.15);
        fg = semantic.actionPrimary;
        break;
      case AppBadgeVariant.neutral:
        bg = semantic.surfaceContainerHigh;
        fg = semantic.textSecondary;
        break;
    }

    return Container(
      padding: ComponentTokens.badgePadding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: ShapeTokens.borderRadiusSm,
        border: Border.all(
          color: fg.withValues(alpha: 0.25),
          width: ShapeTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: ComponentTokens.iconSizeXs, color: fg),
            const SizedBox(width: SpacingTokens.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
