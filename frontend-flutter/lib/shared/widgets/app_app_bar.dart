import 'package:flutter/material.dart';
import '../../core/design_system/layout_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';
import '../../core/network/backend_health_manager.dart';
import 'app_bouncy_tap.dart';
import 'app_logo.dart';

/// Top Application Bar with SKOPOS branding, backend status pill, and action buttons.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isBackendConnected = true,
    this.healthState,
    this.onTapStatus,
    this.showDrawerMenu = true,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final bool isBackendConnected;
  final BackendHealthState? healthState;
  final VoidCallback? onTapStatus;
  final bool showDrawerMenu;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(LayoutTokens.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    final effectiveState = healthState ??
        (isBackendConnected ? BackendHealthState.online : BackendHealthState.offline);

    final (statusColor, statusLabel, statusIcon) = switch (effectiveState) {
      BackendHealthState.online => (
          semantic.statusSuccess,
          'Online',
          null,
        ),
      BackendHealthState.wakingUp => (
          semantic.statusWarning,
          'Waking Server...',
          Icons.refresh_rounded,
        ),
      BackendHealthState.checking => (
          semantic.statusInfo,
          'Checking...',
          Icons.sync_rounded,
        ),
      BackendHealthState.offline || BackendHealthState.unknown => (
          semantic.statusError,
          'Offline',
          Icons.power_off_rounded,
        ),
    };

    return AppBar(
      leading: showDrawerMenu
          ? Builder(
              builder: (drawerContext) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Open Navigation Drawer',
                onPressed: () => Scaffold.of(drawerContext).openDrawer(),
              ),
            )
          : null,
      titleSpacing: showDrawerMenu ? 0 : SpacingTokens.lg,
      title: Row(
        children: [
          const AppLogo(
            size: 28,
            showBorder: true,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: semantic.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: textTheme.labelSmall?.copyWith(
                    color: semantic.textMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: SpacingTokens.md),

          // Backend Connection Indicator with Tap to Wake
          AppBouncyTap(
            onTap: onTapStatus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  if (statusIcon != null) ...[
                    Icon(
                      statusIcon,
                      size: 10,
                      color: statusColor,
                    ),
                  ] else ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
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
      actions: actions,
    );
  }
}

