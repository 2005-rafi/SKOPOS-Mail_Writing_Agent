import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/component_tokens.dart';
import '../../../core/design_system/layout_tokens.dart';
import '../../../core/design_system/semantic_colors.dart';
import '../../../core/design_system/shape_tokens.dart';
import '../../../core/design_system/spacing_tokens.dart';
import '../../../core/design_system/theme_mode_controller.dart';
import '../../../core/network/backend_health_manager.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_segmented_control.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/writing_preferences_editor.dart';
import '../../compose/domain/compose_models.dart';
import 'settings_controller.dart';

/// Screen for managing credentials, dynamic provider models, API URL,
/// theme preferences, and segregated Email vs Letter default settings.
/// Adheres to a sleek, minimalist grouped layout with dynamic segmented controls.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final SettingsController controller;
  final ThemeModeController themeController;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _groqKeyController;
  late final TextEditingController _geminiKeyController;
  bool _obscureGroq = true;
  bool _obscureGemini = true;

  // Segregated Preferences State: 0 for Email, 1 for Letter
  int _preferencesTab = 0;

  // Working settings
  late SettingsModel _emailSettings;
  late SettingsModel _letterSettings;

  @override
  void initState() {
    super.initState();
    _groqKeyController = TextEditingController(text: widget.controller.groqKey);
    _geminiKeyController = TextEditingController(text: widget.controller.geminiKey);

    _emailSettings = widget.controller.defaultEmailSettings;
    _letterSettings = widget.controller.defaultLetterSettings;
  }

  @override
  void dispose() {
    _groqKeyController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }

  void _saveCredentials() async {
    await widget.controller.saveGroqKey(_groqKeyController.text);
    await widget.controller.saveGeminiKey(_geminiKeyController.text);
    if (mounted) {
      AppSnackbar.show(
        context,
        message: 'AI credentials saved successfully',
        type: AppSnackbarType.success,
      );
    }
  }

  void _saveEmailDefaults() async {
    await widget.controller.updateDefaultEmailSettings(_emailSettings);
    if (mounted) {
      AppSnackbar.show(
        context,
        message: 'Default Email preferences saved',
        type: AppSnackbarType.success,
      );
    }
  }

  void _saveLetterDefaults() async {
    await widget.controller.updateDefaultLetterSettings(_letterSettings);
    if (mounted) {
      AppSnackbar.show(
        context,
        message: 'Default Letter preferences saved',
        type: AppSnackbarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([widget.controller, widget.themeController]),
      builder: (context, _) {
        final healthState = widget.controller.healthState;
        final (statusColor, statusLabel) = switch (healthState) {
          BackendHealthState.online => (semantic.statusSuccess, 'Online'),
          BackendHealthState.wakingUp => (semantic.statusWarning, 'Waking Server... (~30s)'),
          BackendHealthState.checking => (semantic.statusInfo, 'Checking...'),
          BackendHealthState.offline || BackendHealthState.unknown => (semantic.statusError, 'Offline'),
        };

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LayoutTokens.maxContentWidth),
            child: SingleChildScrollView(
              padding: SpacingTokens.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Minimalist Brand Identity Banner
                  SettingsGroup(
                    children: [
                      Row(
                        children: [
                          const AppLogo(
                            size: 40,
                            showBorder: true,
                          ),
                          const SizedBox(width: SpacingTokens.md),
                          Text(
                            AppConfig.appName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: semantic.textPrimary,
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          AppBadge(
                            label: 'v${AppConfig.version}',
                            variant: AppBadgeVariant.neutral,
                          ),
                          const Spacer(),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.45),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.lg),

                  // 2. Appearance & Theme Settings
                  SettingsGroup(
                    title: 'Appearance & Theme',
                    icon: Icons.palette_outlined,
                    children: [
                      Text(
                        'Theme Mode',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: semantic.textSecondary,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      AppSegmentedControl<ThemeMode>(
                        options: const [
                          SegmentOption(
                            value: ThemeMode.system,
                            label: 'System',
                            icon: Icons.brightness_auto_rounded,
                          ),
                          SegmentOption(
                            value: ThemeMode.light,
                            label: 'Light',
                            icon: Icons.light_mode_rounded,
                          ),
                          SegmentOption(
                            value: ThemeMode.dark,
                            label: 'Dark',
                            icon: Icons.dark_mode_rounded,
                          ),
                        ],
                        selectedValue: widget.themeController.themeMode,
                        onSelected: (mode) => widget.themeController.setThemeMode(mode),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.lg),

                  // 4. AI Provider & Dynamic Models
                  SettingsGroup(
                    title: 'AI Provider & Credentials',
                    icon: Icons.tune_rounded,
                    children: [
                      AppDropdown<String>(
                        label: 'Active AI Provider',
                        selectedValue: widget.controller.activeProvider,
                        items: const [
                          AppDropdownOption(value: 'groq', label: 'Groq Cloud (Fast Inference)'),
                          AppDropdownOption(value: 'gemini', label: 'Google Gemini (Free Tier)'),
                          AppDropdownOption(value: 'mock', label: 'Mock Deterministic Engine'),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            widget.controller.setActiveProvider(val);
                          }
                        },
                      ),
                      const SizedBox(height: SpacingTokens.md),

                      // Dynamic Model Selection
                      AppDropdown<String>(
                        label: 'Model Selection',
                        selectedValue: widget.controller.selectedModel,
                        items: widget.controller.availableModels.map((m) {
                          return AppDropdownOption(
                            value: m.id,
                            label: m.label,
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            widget.controller.setModel(val);
                          }
                        },
                      ),
                      const SizedBox(height: SpacingTokens.md),

                      // Provider Specific API Keys
                      if (widget.controller.activeProvider == 'groq') ...[
                        AppTextField(
                          controller: _groqKeyController,
                          label: 'Groq API Key',
                          hint: 'gsk_...',
                          obscureText: _obscureGroq,
                          helperText: 'Stored securely using platform-level encrypted keyrings',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureGroq ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: ComponentTokens.iconSizeSm,
                              color: semantic.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscureGroq = !_obscureGroq),
                          ),
                        ),
                      ] else if (widget.controller.activeProvider == 'gemini') ...[
                        AppTextField(
                          controller: _geminiKeyController,
                          label: 'Gemini API Key',
                          hint: 'AIzaSy...',
                          obscureText: _obscureGemini,
                          helperText: 'Stored securely using platform-level encrypted keyrings',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureGemini ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: ComponentTokens.iconSizeSm,
                              color: semantic.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscureGemini = !_obscureGemini),
                          ),
                        ),
                      ],
                      const SizedBox(height: SpacingTokens.md),

                      AppButton(
                        text: 'Save AI Credentials',
                        variant: AppButtonVariant.primary,
                        isFullWidth: true,
                        onPressed: _saveCredentials,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.lg),

                  // 5. Segregated Default Preferences (Email vs Letter)
                  SettingsGroup(
                    title: 'Default Writing Preferences',
                    icon: Icons.auto_stories_outlined,
                    children: [
                      AppSegmentedControl<int>(
                        options: const [
                          SegmentOption(
                            value: 0,
                            label: 'Email Defaults',
                            icon: Icons.mail_outline_rounded,
                          ),
                          SegmentOption(
                            value: 1,
                            label: 'Letter Defaults',
                            icon: Icons.description_outlined,
                          ),
                        ],
                        selectedValue: _preferencesTab,
                        onSelected: (tab) => setState(() => _preferencesTab = tab),
                      ),
                      const SizedBox(height: SpacingTokens.md),

                      // Animated cross-fade between Email and Letter editors
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _preferencesTab == 0
                            ? WritingPreferencesEditor(
                                key: const ValueKey('settings_email_editor'),
                                settings: _emailSettings,
                                saveButtonText: 'Save Default Email Preferences',
                                onChanged: (updated) => setState(() => _emailSettings = updated),
                                onSave: _saveEmailDefaults,
                              )
                            : WritingPreferencesEditor(
                                key: const ValueKey('settings_letter_editor'),
                                settings: _letterSettings,
                                saveButtonText: 'Save Default Letter Preferences',
                                onChanged: (updated) => setState(() => _letterSettings = updated),
                                onSave: _saveLetterDefaults,
                              ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
