import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/design_system/app_theme.dart';
import 'bootstrap.dart';
import 'router/app_router.dart';

/// Root Application Widget configuring themes, routing, and scaffolds.
class SkoposApp extends StatelessWidget {
  const SkoposApp({
    super.key,
    required this.container,
  });

  final AppContainer container;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: container.themeController,
      builder: (context, _) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: container.themeController.themeMode,
          home: AppScaffold(
            composeController: container.composeController,
            rewriteController: container.rewriteController,
            historyController: container.historyController,
            settingsController: container.settingsController,
            themeController: container.themeController,
          ),
        );
      },
    );
  }
}
