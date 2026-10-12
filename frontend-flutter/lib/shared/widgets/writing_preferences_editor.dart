import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/spacing_tokens.dart';
import '../../features/compose/domain/compose_models.dart';
import 'app_button.dart';
import 'app_dropdown.dart';
import 'app_switch.dart';
import 'app_text_field.dart';

/// Unified, reusable writing preferences editor.
/// Eliminates code duplication across Settings and Compose/Rewrite bottom sheets.
/// Features dynamic smooth expansion for custom tone and style inputs.
class WritingPreferencesEditor extends StatefulWidget {
  const WritingPreferencesEditor({
    super.key,
    required this.settings,
    required this.onChanged,
    this.saveButtonText,
    this.onSave,
    this.showSaveButton = true,
  });

  final SettingsModel settings;
  final ValueChanged<SettingsModel> onChanged;
  final String? saveButtonText;
  final VoidCallback? onSave;
  final bool showSaveButton;

  @override
  State<WritingPreferencesEditor> createState() => _WritingPreferencesEditorState();
}

class _WritingPreferencesEditorState extends State<WritingPreferencesEditor> {
  late SettingsModel _current;
  late final TextEditingController _customToneController;
  late final TextEditingController _customStyleController;

  @override
  void initState() {
    super.initState();
    _current = widget.settings;
    _customToneController = TextEditingController(text: _current.customTone ?? '');
    _customStyleController = TextEditingController(text: _current.customStyle ?? '');
  }

  @override
  void didUpdateWidget(covariant WritingPreferencesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _current = widget.settings;
      if (_customToneController.text != (_current.customTone ?? '')) {
        _customToneController.text = _current.customTone ?? '';
      }
      if (_customStyleController.text != (_current.customStyle ?? '')) {
        _customStyleController.text = _current.customStyle ?? '';
      }
    }
  }

  @override
  void dispose() {
    _customToneController.dispose();
    _customStyleController.dispose();
    super.dispose();
  }

  void _updateSettings(SettingsModel updated) {
    setState(() => _current = updated);
    widget.onChanged(updated);
  }

  void _onCustomToneChanged(String val) {
    _updateSettings(_current.copyWith(customTone: val.trim()));
  }

  void _onCustomStyleChanged(String val) {
    _updateSettings(_current.copyWith(customStyle: val.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    final isLetter = _current.contentType == 'letter';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tone Dropdown
        AppDropdown<String>(
          label: isLetter ? 'Letter Tone' : 'Email Tone',
          selectedValue: _current.tone,
          items: AppConfig.supportedTones
              .map((t) => AppDropdownOption(
                    value: t,
                    label: t == 'custom'
                        ? 'Other / Custom Tone...'
                        : t[0].toUpperCase() + t.substring(1),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              _updateSettings(_current.copyWith(
                tone: val,
                customTone: val == 'custom' ? _customToneController.text.trim() : null,
              ));
            }
          },
        ),

        // Dynamic smooth reveal for Custom Tone Details
        AnimatedSize(
          duration: MotionTokens.durationStandard,
          curve: MotionTokens.curveStandard,
          child: _current.tone == 'custom'
              ? Padding(
                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                  child: AppTextField(
                    controller: _customToneController,
                    label: 'Describe Your Specific Tone',
                    hint: isLetter
                        ? 'e.g. Formal legal address, authoritative complaint...'
                        : 'e.g. Firm yet respectful, apologetic but resolute...',
                    maxLines: 2,
                    onChanged: _onCustomToneChanged,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: SpacingTokens.md),

        // Stylistic Approach Dropdown
        AppDropdown<String>(
          label: isLetter ? 'Letter Stylistic Approach' : 'Email Stylistic Approach',
          selectedValue: _current.style,
          items: AppConfig.supportedStyles
              .map((s) => AppDropdownOption(
                    value: s,
                    label: s == 'custom'
                        ? 'Other / Custom Style...'
                        : s[0].toUpperCase() + s.substring(1),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              _updateSettings(_current.copyWith(
                style: val,
                customStyle: val == 'custom' ? _customStyleController.text.trim() : null,
              ));
            }
          },
        ),

        // Dynamic smooth reveal for Custom Style Details
        AnimatedSize(
          duration: MotionTokens.durationStandard,
          curve: MotionTokens.curveStandard,
          child: _current.style == 'custom'
              ? Padding(
                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                  child: AppTextField(
                    controller: _customStyleController,
                    label: 'Describe Your Specific Style',
                    hint: isLetter
                        ? 'e.g. Formal sections, background context, legal precision...'
                        : 'e.g. Bullet points, bold headers, direct BLUF summary...',
                    maxLines: 2,
                    onChanged: _onCustomStyleChanged,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: SpacingTokens.md),

        // Target Word Limit Slider with badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target Word Limit',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: semantic.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: semantic.actionPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_current.maxWords} words',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: semantic.actionPrimary,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _current.maxWords.toDouble(),
          min: AppConfig.absoluteMinWords.toDouble(),
          max: AppConfig.absoluteMaxWords.toDouble(),
          divisions: 48,
          activeColor: semantic.actionPrimary,
          inactiveColor: semantic.outlineVariant,
          onChanged: (val) {
            _updateSettings(_current.copyWith(maxWords: val.round()));
          },
        ),

        const SizedBox(height: SpacingTokens.xs),

        // Formatting Toggles
        AppSwitch(
          title: isLetter ? 'Letter Title / Subject Required' : 'Subject Line Required',
          value: _current.subjectEnabled,
          onChanged: (val) => _updateSettings(_current.copyWith(subjectEnabled: val)),
        ),
        AppSwitch(
          title: isLetter ? 'Formal Salutation Required' : 'Opening Salutation Required',
          value: _current.salutationEnabled,
          onChanged: (val) => _updateSettings(_current.copyWith(salutationEnabled: val)),
        ),
        AppSwitch(
          title: isLetter ? 'Formal Sign-off Required' : 'Closing Sign-off Required',
          value: _current.closingEnabled,
          onChanged: (val) => _updateSettings(_current.copyWith(closingEnabled: val)),
        ),

        if (widget.showSaveButton && widget.onSave != null) ...[
          const SizedBox(height: SpacingTokens.lg),
          AppButton(
            text: widget.saveButtonText ?? 'Save Preferences',
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            onPressed: widget.onSave,
          ),
        ],
      ],
    );
  }
}
