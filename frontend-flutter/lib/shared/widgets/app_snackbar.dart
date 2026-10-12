import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';

enum AppSnackbarType { success, error, info }

/// Standardized notification toast helper.
abstract class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final semantic = context.semanticColors;

    Color bg;
    Color fg;
    IconData icon;

    switch (type) {
      case AppSnackbarType.success:
        bg = semantic.statusSuccess;
        fg = Colors.white;
        icon = Icons.check_circle_outline_rounded;
        break;
      case AppSnackbarType.error:
        bg = semantic.statusError;
        fg = Colors.white;
        icon = Icons.error_outline_rounded;
        break;
      case AppSnackbarType.info:
        bg = semantic.surfaceContainerHighest;
        fg = semantic.textPrimary;
        icon = Icons.info_outline_rounded;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: ComponentTokens.iconSizeMd, color: fg),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
        backgroundColor: bg,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: ShapeTokens.borderRadiusMd),
        margin: const EdgeInsets.all(SpacingTokens.lg),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1.0),
          curve: MotionTokens.curveStandard,
        ),
      ),
    );
  }
}
