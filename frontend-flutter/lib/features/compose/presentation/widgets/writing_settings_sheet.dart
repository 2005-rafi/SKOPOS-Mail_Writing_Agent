import 'package:flutter/material.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../../../../shared/widgets/writing_preferences_editor.dart';
import '../../domain/compose_models.dart';

/// Modal bottom sheet allowing users to adjust writing preferences
/// with segregated Email/Letter modes and custom tone/style descriptions.
/// Built using reusable [AppSegmentedControl] and [WritingPreferencesEditor].
class WritingSettingsSheet extends StatefulWidget {
  const WritingSettingsSheet({
    super.key,
    required this.initialSettings,
    required this.onSave,
  });

  final SettingsModel initialSettings;
  final ValueChanged<SettingsModel> onSave;

  @override
  State<WritingSettingsSheet> createState() => _WritingSettingsSheetState();
}

class _WritingSettingsSheetState extends State<WritingSettingsSheet> {
  late SettingsModel _workingSettings;

  @override
  void initState() {
    super.initState();
    _workingSettings = widget.initialSettings;
  }

  void _handleSave() {
    widget.onSave(_workingSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(ShapeTokens.radiusLg)),
      ),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.xl,
        SpacingTokens.lg,
        SpacingTokens.xl,
        SpacingTokens.xl,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Writing Preferences',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: semantic.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: semantic.textSecondary, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),

              // Content Type Segregation (Email vs Letter)
              AppSegmentedControl<String>(
                options: const [
                  SegmentOption(
                    value: 'email',
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                  ),
                  SegmentOption(
                    value: 'letter',
                    label: 'Letter',
                    icon: Icons.description_outlined,
                  ),
                ],
                selectedValue: _workingSettings.contentType,
                onSelected: (type) {
                  setState(() {
                    _workingSettings = _workingSettings.copyWith(contentType: type);
                  });
                },
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Unified Writing Preferences Editor
              WritingPreferencesEditor(
                settings: _workingSettings,
                showSaveButton: false,
                onChanged: (updated) {
                  setState(() => _workingSettings = updated);
                },
              ),
              const SizedBox(height: SpacingTokens.xl),

              // Apply Action Button
              AppButton(
                text: 'Apply Preferences',
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
