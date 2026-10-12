import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/layout_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';
import '../../core/design_system/theme_mode_controller.dart';
import '../../core/network/backend_health_manager.dart';
import 'app_logo.dart';

/// Navigation Drawer component for SKOPOS with brand logo,
/// section navigation, connection diagnostics, and theme switching.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectIndex,
    required this.healthState,
    required this.onTapHealth,
    required this.themeController,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectIndex;
  final BackendHealthState healthState;
  final VoidCallback onTapHealth;
  final ThemeModeController themeController;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    final (statusColor, statusLabel) = switch (healthState) {
      BackendHealthState.online => (semantic.statusSuccess, 'Backend Online'),
      BackendHealthState.wakingUp => (semantic.statusWarning, 'Waking Up... (~30s)'),
      BackendHealthState.checking => (semantic.statusInfo, 'Checking Status...'),
      BackendHealthState.offline || BackendHealthState.unknown => (semantic.statusError, 'Backend Offline'),
    };

    return Drawer(
      backgroundColor: semantic.surfaceContainer,
      child: SafeArea(
        child: Column(
          children: [
            // Brand Header with AppLogo
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.xl,
              ),
              decoration: BoxDecoration(
                color: semantic.surfaceContainerHigh,
                border: Border(
                  bottom: BorderSide(
                    color: semantic.outlineVariant,
                    width: ShapeTokens.borderWidthHairline,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(
                        size: 42,
                        showBorder: true,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConfig.appName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: semantic.textPrimary,
                              ),
                            ),
                            Text(
                              AppConfig.appTagline,
                              style: textTheme.labelSmall?.copyWith(
                                color: semantic.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: SpacingTokens.md, height: SpacingTokens.md),
                  // Tap to probe connection chip
                  InkWell(
                    onTap: onTapHealth,
                    borderRadius: ShapeTokens.borderRadiusFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: ShapeTokens.borderRadiusFull,
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: ShapeTokens.borderWidthHairline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.md,
                ),
                children: [
                  _DrawerNavItem(
                    icon: Icons.edit_note_rounded,
                    label: 'Write / Compose',
                    subtitle: 'Create email or letter from scenario',
                    isSelected: currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectIndex(0);
                    },
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  _DrawerNavItem(
                    icon: Icons.auto_fix_high_rounded,
                    label: 'Rewrite & Polish',
                    subtitle: 'Enhance and restyle existing draft',
                    isSelected: currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectIndex(1);
                    },
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  _DrawerNavItem(
                    icon: Icons.history_rounded,
                    label: 'Local History',
                    subtitle: 'Saved offline communications',
                    isSelected: currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectIndex(2);
                    },
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  _DrawerNavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    subtitle: 'Preferences, models, keys, theme',
                    isSelected: currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectIndex(3);
                    },
                  ),
                ],
              ),
            ),

            // Drawer Footer: Quick Theme Toggle & About Metadata
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.md,
              ),
              decoration: BoxDecoration(
                color: semantic.surfaceContainerHigh,
                border: Border(
                  top: BorderSide(
                    color: semantic.outlineVariant,
                    width: ShapeTokens.borderWidthHairline,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              themeController.isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: ComponentTokens.iconSizeSm,
                              color: semantic.textSecondary,
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Flexible(
                              child: Text(
                                'Dark Mode',
                                style: textTheme.bodySmall?.copyWith(
                                  color: semantic.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: themeController.isDarkMode,
                        activeColor: semantic.actionPrimary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          themeController.setThemeMode(
                            val ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'v${AppConfig.version}',
                          style: textTheme.labelSmall?.copyWith(
                            color: semantic.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Flexible(
                        child: Text(
                          'Offline-First',
                          style: textTheme.labelSmall?.copyWith(
                            color: semantic.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected
          ? semantic.actionPrimary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: ShapeTokens.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: ShapeTokens.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? semantic.actionPrimary
                      : semantic.surfaceContainerHighest,
                  borderRadius: ShapeTokens.borderRadiusSm,
                ),
                child: Icon(
                  icon,
                  size: ComponentTokens.iconSizeMd,
                  color: isSelected
                      ? semantic.onActionPrimary
                      : semantic.textSecondary,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? semantic.actionPrimary : semantic.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.labelSmall?.copyWith(
                        color: semantic.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: semantic.actionPrimary,
                    borderRadius: ShapeTokens.borderRadiusFull,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
