import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/spacing_tokens.dart';
import 'app_button.dart';

/// Empty state presentation with icon, title, description, and optional action.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.customVisual,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final IconData icon;
  final Widget? customVisual;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customVisual != null) ...[
              customVisual!,
            ] else ...[
              Container(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: ComponentTokens.iconSizeXl,
                  color: semantic.actionPrimary,
                ),
              ),
            ],
            const SizedBox(height: SpacingTokens.lg),

            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: semantic.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.lg),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.tonal,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
