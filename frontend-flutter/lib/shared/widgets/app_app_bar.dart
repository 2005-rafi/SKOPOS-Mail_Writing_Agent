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
        mainAxisSize: MainAxisSize.min,
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
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        Padding(
          padding: const EdgeInsets.only(right: SpacingTokens.md),
          child: AppBouncyTap(
            onTap: onTapStatus,
            child: Tooltip(
              message: 'Server: $statusLabel (Tap to recheck)',
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.32),
                    width: ShapeTokens.borderWidthHairline,
                  ),
                ),
                child: Container(
                  width: 8,
                  height: 8,
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

