import 'package:flutter/material.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../compose/domain/compose_models.dart';
import '../../domain/history_item.dart';

/// Clean bottom sheet modal for inspecting complete historical communication details.
class HistoryDetailSheet extends StatelessWidget {
  const HistoryDetailSheet({
    super.key,
    required this.item,
    required this.onLoadIntoCompose,
    required this.onDelete,
  });

  final HistoryItem item;
  final ValueChanged<GenerateResponse> onLoadIntoCompose;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(ShapeTokens.radiusLg)),
      ),
      padding: const EdgeInsets.all(SpacingTokens.xl),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppBadge(
                        label: item.type.toUpperCase(),
                        variant: item.type == 'email'
                            ? AppBadgeVariant.brand
                            : AppBadgeVariant.neutral,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      AppBadge(
                        label: item.provider.toUpperCase(),
                        variant: AppBadgeVariant.neutral,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(
                        item.model,
                        style: textTheme.labelSmall?.copyWith(color: semantic.textMuted),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: semantic.textSecondary, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),

              if (item.scenario != null && item.scenario!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainerHigh,
                    borderRadius: ShapeTokens.borderRadiusSm,
                    border: Border.all(
                      color: semantic.outlineVariant,
                      width: ShapeTokens.borderWidthHairline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original Scenario / Intent',
                        style: textTheme.labelSmall?.copyWith(
                          color: semantic.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.scenario!,
                        style: textTheme.bodySmall?.copyWith(color: semantic.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],

              // Document Content
              if (item.output.subject != null) ...[
                Text(
                  'Subject',
                  style: textTheme.labelSmall?.copyWith(color: semantic.textMuted),
                ),
                Text(
                  TextSanitizer.toPlainText(item.output.subject!),
                  style: textTheme.titleMedium?.copyWith(
                    color: semantic.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],
              if (item.output.salutation != null) ...[
                Text(
                  TextSanitizer.sanitize(item.output.salutation!),
                  style: textTheme.bodyMedium?.copyWith(color: semantic.textPrimary),
                ),
                const SizedBox(height: SpacingTokens.sm),
              ],
              ...TextSanitizer.extractParagraphs(item.output.body).map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: Text(
                    p,
                    style: textTheme.bodyMedium?.copyWith(
                      color: semantic.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (item.output.closing != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  TextSanitizer.sanitize(item.output.closing!),
                  style: textTheme.bodyMedium?.copyWith(color: semantic.textSecondary),
                ),
              ],
              const SizedBox(height: SpacingTokens.xl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Copy',
                      variant: AppButtonVariant.outlined,
                      leadingIcon: Icons.content_copy_rounded,
                      onPressed: () {
                        ClipboardHelper.copyPlainText(
                          '${item.output.subject != null ? "Subject: ${item.output.subject}\n\n" : ""}${item.output.salutation != null ? "${item.output.salutation}\n\n" : ""}${item.output.body}${item.output.closing != null ? "\n\n${item.output.closing}" : ""}',
                        );
                        Navigator.of(context).pop();
                        AppSnackbar.show(
                          context,
                          message: 'Copied document to clipboard',
                          type: AppSnackbarType.success,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: AppButton(
                      text: 'Load in Write',
                      variant: AppButtonVariant.primary,
                      leadingIcon: Icons.edit_note_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onLoadIntoCompose(item.toGenerateResponse());
                      },
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  AppIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete document',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
