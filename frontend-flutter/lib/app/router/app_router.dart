import 'package:flutter/material.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/theme_mode_controller.dart';
import '../../features/compose/presentation/compose_controller.dart';
import '../../features/compose/presentation/compose_screen.dart';
import '../../features/history/presentation/history_controller.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/rewrite/presentation/rewrite_controller.dart';
import '../../features/rewrite/presentation/rewrite_screen.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_app_bar.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/app_navigation_bar.dart';


/// Root Application Navigation Container hosting the persistent app bar and bottom tabs.
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.composeController,
    required this.rewriteController,
    required this.historyController,
    required this.settingsController,
    required this.themeController,
  });

  final ComposeController composeController;
  final RewriteController rewriteController;
  final HistoryController historyController;
  final SettingsController settingsController;
  final ThemeModeController themeController;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    if (index == 2) {
      widget.historyController.loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ComposeScreen(
        controller: widget.composeController,
        onNavigateToSettings: () => setState(() => _currentIndex = 3),
      ),
      RewriteScreen(
        controller: widget.rewriteController,
        onNavigateToSettings: () => setState(() => _currentIndex = 3),
      ),
      HistoryScreen(
        controller: widget.historyController,
        onLoadIntoCompose: (response) {
          widget.composeController.loadFromHistory(response);
          setState(() => _currentIndex = 0);
        },
      ),
      SettingsScreen(
        controller: widget.settingsController,
        themeController: widget.themeController,
      ),
    ];

    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppAppBar(
            title: 'SKOPOS',
            isBackendConnected: widget.settingsController.isBackendConnected,
            healthState: widget.settingsController.healthState,
            onTapStatus: () {
              widget.settingsController.checkBackendHealth(force: true);
            },
          ),
          drawer: AppDrawer(
            currentIndex: _currentIndex,
            onSelectIndex: (index) {
              setState(() => _currentIndex = index);
            },
            healthState: widget.settingsController.healthState,
            onTapHealth: () {
              widget.settingsController.checkBackendHealth(force: true);
            },
            themeController: widget.themeController,
          ),
          body: AnimatedSwitcher(
            duration: MotionTokens.durationStandard,
            switchInCurve: MotionTokens.curveStandard,
            switchOutCurve: MotionTokens.curveStandard,
            child: screens[_currentIndex],
          ),
          bottomNavigationBar: AppNavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
          ),
        );
      },
    );
  }
}
