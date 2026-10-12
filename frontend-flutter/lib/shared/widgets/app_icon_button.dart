import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';

import 'app_bouncy_tap.dart';

/// Accessible icon button with required tooltip and theme-aware states.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = ComponentTokens.iconSizeMd,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final isEnabled = onPressed != null;

    final iconColor = color ?? (isEnabled ? semantic.textPrimary : semantic.textMuted);

    return Tooltip(
      message: tooltip,
      child: AppBouncyTap(
        enabled: isEnabled,
        onTap: onPressed,
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: ShapeTokens.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: size,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
