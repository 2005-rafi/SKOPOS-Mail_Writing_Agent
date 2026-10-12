import 'package:flutter/material.dart';
import '../../../core/design_system/layout_tokens.dart';
import '../../../core/design_system/spacing_tokens.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_snackbar.dart';

import 'compose_controller.dart';
import 'widgets/generated_output_card.dart';
import 'widgets/refinement_bar.dart';
import 'widgets/scenario_input_card.dart';
import 'widgets/writing_settings_sheet.dart';

/// Screen for composing and iteratively refining AI-generated communications.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    super.key,
    required this.controller,
  });

  final ComposeController controller;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController _scenarioController = TextEditingController();
  final TextEditingController _refineController = TextEditingController();

  @override
  void dispose() {
    _scenarioController.dispose();
    _refineController.dispose();
    super.dispose();
  }

  void _handleGenerate() async {
    final success = await widget.controller.generate(_scenarioController.text);
    if (!success && mounted && widget.controller.errorMessage != null) {
      AppSnackbar.show(
        context,
        message: widget.controller.errorMessage!,
        type: AppSnackbarType.error,
      );
    }
  }

  void _handleRefine() async {
    final success = await widget.controller.refine(_refineController.text);
    if (success && mounted) {
      _refineController.clear();
      AppSnackbar.show(
        context,
        message: 'Communication refined successfully',
        type: AppSnackbarType.success,
      );
    } else if (!success && mounted && widget.controller.errorMessage != null) {
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
                  ScenarioInputCard(
                    controller: _scenarioController,
                    isLoading: widget.controller.state == ComposeState.generating,
                    onGenerate: _handleGenerate,
                    onOpenSettings: _showSettingsModal,
                  ),
                  const SizedBox(height: SpacingTokens.xl),

                  if (currentOutput != null) ...[
                    GeneratedOutputCard(response: currentOutput),
                    const SizedBox(height: SpacingTokens.lg),
                    RefinementBar(
                      controller: _refineController,
                      isLoading: widget.controller.state == ComposeState.refining,
                      onRefine: _handleRefine,
                    ),
                  ] else if (!isLoading) ...[
                    const AppEmptyState(
                      title: 'Ready to write with precision',
                      description: 'Enter your situation or message goal above and tap Generate.',
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
