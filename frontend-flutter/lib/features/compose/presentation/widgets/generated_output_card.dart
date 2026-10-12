import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_divider.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../domain/compose_models.dart';

/// Card presenting generated communication with rich paragraph formatting and copy actions.
class GeneratedOutputCard extends StatelessWidget {
  const GeneratedOutputCard({
    super.key,
    required this.response,
  });

  final GenerateResponse response;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    final output = response.output;

    final paragraphs = TextSanitizer.extractParagraphs(output.body);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Metadata Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: SpacingTokens.xs,
                runSpacing: SpacingTokens.xs,
                children: [
                  AppBadge(
                    label: '${response.provider.toUpperCase()} • ${response.model}',
                    variant: AppBadgeVariant.brand,
                    icon: Icons.memory_rounded,
                  ),
                  AppBadge(
                    label: '${response.wordCount} words',
                    variant: AppBadgeVariant.neutral,
                    icon: Icons.notes_rounded,
                  ),
                  if (response.validation.repaired)
                    const AppBadge(
                      label: 'Repaired (1 Pass)',
                      variant: AppBadgeVariant.warning,
                      icon: Icons.build_circle_outlined,
                    )
                  else
                    const AppBadge(
                      label: 'Validated',
                      variant: AppBadgeVariant.success,
                      icon: Icons.verified_outlined,
                    ),
                ],
              ),
              AppIconButton(
                icon: Icons.copy_all_rounded,
                tooltip: 'Copy Full Document',
                onPressed: () => _copyAll(context),
              ),
            ],
          ),

          const AppDivider(),

          // Subject Line (if present)
          if (output.subject != null && output.subject!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: semantic.surfaceContainer,
                borderRadius: ShapeTokens.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUBJECT',
                          style: textTheme.labelSmall?.copyWith(
                            color: semantic.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          TextSanitizer.toPlainText(output.subject!),
                          style: textTheme.titleSmall?.copyWith(
                            color: semantic.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.content_copy_rounded,
                    tooltip: 'Copy Subject',
                    size: ComponentTokens.iconSizeSm,
                    onPressed: () {
                      ClipboardHelper.copyPlainText(output.subject!);
                      AppSnackbar.show(
                        context,
                        message: 'Subject copied to clipboard',
                        type: AppSnackbarType.success,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
          ],

          // Salutation (if present)
          if (output.salutation != null && output.salutation!.isNotEmpty) ...[
            Text(
              TextSanitizer.sanitize(output.salutation!),
              style: textTheme.bodyLarge?.copyWith(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
          ],

          // Main Body Paragraphs
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                child: Text(
                  p,
                  style: textTheme.bodyLarge?.copyWith(
                    color: semantic.textPrimary,
                    height: 1.5,
                  ),
                ),
              )),

          // Closing Sign-off (if present)
          if (output.closing != null && output.closing!.isNotEmpty) ...[
            Text(
              TextSanitizer.sanitize(output.closing!),
              style: textTheme.bodyMedium?.copyWith(
                color: semantic.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
          ],

          const AppDivider(),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Copy Body',
                variant: AppButtonVariant.outlined,
                leadingIcon: Icons.content_copy_rounded,
                onPressed: () {
                  ClipboardHelper.copyPlainText(TextSanitizer.toPlainText(output.body));
                  AppSnackbar.show(
                    context,
                    message: 'Body copied to clipboard',
                    type: AppSnackbarType.success,
                  );
                },
              ),
              const SizedBox(width: SpacingTokens.sm),
              AppButton(
                text: 'Copy All',
                variant: AppButtonVariant.primary,
                leadingIcon: Icons.done_all_rounded,
                onPressed: () => _copyAll(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyAll(BuildContext context) {
    final buffer = StringBuffer();
    final out = response.output;

    if (out.subject != null && out.subject!.isNotEmpty) {
      buffer.writeln('Subject: ${TextSanitizer.toPlainText(out.subject!)}');
      buffer.writeln();
    }
    if (out.salutation != null && out.salutation!.isNotEmpty) {
      buffer.writeln(TextSanitizer.sanitize(out.salutation!));
      buffer.writeln();
    }
    buffer.writeln(TextSanitizer.toPlainText(out.body));
    if (out.closing != null && out.closing!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(TextSanitizer.sanitize(out.closing!));
    }

    ClipboardHelper.copyPlainText(buffer.toString().trim());
    AppSnackbar.show(
      context,
      message: 'Full communication copied to clipboard',
      type: AppSnackbarType.success,
    );
  }
}
