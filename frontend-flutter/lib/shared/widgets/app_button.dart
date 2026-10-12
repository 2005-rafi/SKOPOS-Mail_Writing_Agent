import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';
import 'app_bouncy_tap.dart';

enum AppButtonVariant { primary, secondary, tonal, outlined, destructive, text }

/// Standardized, accessible button with loading and disabled states.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.tooltip,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isEnabled ? semantic.actionPrimary : semantic.outlineVariant;
        foregroundColor = isEnabled ? semantic.onActionPrimary : semantic.textMuted;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isEnabled ? semantic.surfaceContainerHigh : semantic.outlineVariant;
        foregroundColor = isEnabled ? semantic.textPrimary : semantic.textMuted;
        break;
      case AppButtonVariant.tonal:
        backgroundColor = isEnabled ? semantic.surfaceContainer : semantic.outlineVariant;
        foregroundColor = isEnabled ? semantic.actionPrimary : semantic.textMuted;
        break;
      case AppButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? semantic.actionPrimary : semantic.textMuted;
        borderSide = BorderSide(
          color: isEnabled ? semantic.outline : semantic.outlineVariant,
          width: ShapeTokens.borderWidthHairline,
        );
        break;
      case AppButtonVariant.destructive:
        backgroundColor = isEnabled ? semantic.statusError : semantic.outlineVariant;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? semantic.actionPrimary : semantic.textMuted;
        break;
    }

    Widget content = AnimatedSwitcher(
      duration: MotionTokens.durationMicro,
      child: isLoading
          ? SizedBox(
              width: ComponentTokens.iconSizeMd,
              height: ComponentTokens.iconSizeMd,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: foregroundColor,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: ComponentTokens.iconSizeSm, color: foregroundColor),
                  const SizedBox(width: SpacingTokens.sm),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: SpacingTokens.sm),
                  Icon(trailingIcon, size: ComponentTokens.iconSizeSm, color: foregroundColor),
                ],
              ],
            ),
    );

    final buttonWidget = AnimatedContainer(
      duration: MotionTokens.durationMicro,
      height: ComponentTokens.buttonHeight,
      constraints: const BoxConstraints(minWidth: 84.0),
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: ShapeTokens.borderRadiusMd,
          side: borderSide ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: ShapeTokens.borderRadiusMd,
          child: Padding(
            padding: ComponentTokens.buttonPadding,
            child: Center(child: content),
          ),
        ),
      ),
    );

    final bouncyButton = AppBouncyTap(
      enabled: isEnabled,
      child: buttonWidget,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: isFullWidth ? SizedBox(width: double.infinity, child: bouncyButton) : bouncyButton,
      );
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: bouncyButton) : bouncyButton;
  }
}
