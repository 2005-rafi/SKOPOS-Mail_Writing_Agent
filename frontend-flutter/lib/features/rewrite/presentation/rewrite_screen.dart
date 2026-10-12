import 'package:flutter/material.dart';
import '../../../core/design_system/component_tokens.dart';
import '../../../core/design_system/layout_tokens.dart';
import '../../../core/design_system/semantic_colors.dart';
import '../../../core/design_system/spacing_tokens.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_snackbar.dart';

import '../../../shared/widgets/app_text_area.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../compose/presentation/widgets/generated_output_card.dart';
import '../../compose/presentation/widgets/writing_settings_sheet.dart';
import 'rewrite_controller.dart';

/// Screen for transforming existing rough text into polished communication.
class RewriteScreen extends StatefulWidget {
  const RewriteScreen({
    super.key,
    required this.controller,
  });

  final RewriteController controller;

  @override
  State<RewriteScreen> createState() => _RewriteScreenState();
}

class _RewriteScreenState extends State<RewriteScreen> {
  final TextEditingController _draftController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _draftController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  void _handleRewrite() async {
    final success = await widget.controller.rewrite(
      existingContent: _draftController.text,
      instruction: _instructionController.text,
    );
    if (!success && mounted && widget.controller.errorMessage != null) {
      AppSnackbar.show(
        context,
        message: widget.controller.errorMessage!,
        type: AppSnackbarType.error,
      );
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WritingSettingsSheet(
        initialSettings: widget.controller.settings,
        onSave: (newSettings) {
          widget.controller.updateSettings(newSettings);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final currentOutput = widget.controller.currentOutput;
        final isLoading = widget.controller.isLoading;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LayoutTokens.maxContentWidth),
            child: SingleChildScrollView(
              padding: SpacingTokens.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_fix_high_rounded,
                                  size: ComponentTokens.iconSizeMd,
                                  color: semantic.actionPrimary,
                                ),
                                const SizedBox(width: SpacingTokens.sm),
                                Text(
                                  'Rough Draft or Content',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: semantic.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _showSettingsModal,
                              icon: Icon(
                                Icons.tune_rounded,
                                size: ComponentTokens.iconSizeSm,
                                color: semantic.actionPrimary,
                              ),
                              label: Text(
                                'Options',
                                style: textTheme.labelMedium?.copyWith(
                                  color: semantic.actionPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        AppTextArea(
                          controller: _draftController,
                          hint: 'Paste your raw email draft, informal notes, or quick thoughts here...',
                          minLines: 4,
                          maxLines: 8,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        AppTextField(
                          controller: _instructionController,
                          label: 'Rewrite Emphasis / Instruction (Optional)',
                          hint: 'e.g., Make it firmer, emphasize the deadline, make tone polite...',
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        AppButton(
                          text: 'Rewrite Draft',
                          leadingIcon: Icons.auto_fix_normal_rounded,
                          isLoading: isLoading,
                          isFullWidth: true,
                          onPressed: _handleRewrite,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xl),

                  if (currentOutput != null) ...[
                    GeneratedOutputCard(response: currentOutput),
                  ] else if (!isLoading) ...[
                    const AppEmptyState(
                      title: 'Polished revisions at your fingertips',
                      description: 'Paste any draft above, choose your options, and tap Rewrite Draft.',
                      customVisual: AppLogo(size: 64, showBorder: true),
                    ),
                  ],

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
