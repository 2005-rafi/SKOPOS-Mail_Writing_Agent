import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design_system/theme_mode_controller.dart';
import '../core/network/api_client.dart';
import '../core/network/backend_health_manager.dart';
import '../core/storage/history_storage_service.dart';
import '../core/storage/local_settings_store.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/compose/data/compose_repository.dart';
import '../features/compose/presentation/compose_controller.dart';
import '../features/history/data/history_repository.dart';
import '../features/history/presentation/history_controller.dart';
import '../features/rewrite/data/rewrite_repository.dart';
import '../features/rewrite/presentation/rewrite_controller.dart';
import '../features/settings/presentation/settings_controller.dart';

/// Container encapsulating initialized app singletons and feature controllers.
class AppContainer {
  const AppContainer({
    required this.themeController,
    required this.settingsController,
    required this.composeController,
    required this.rewriteController,
    required this.historyController,
  });

  final ThemeModeController themeController;
  final SettingsController settingsController;
  final ComposeController composeController;
  final RewriteController rewriteController;
  final HistoryController historyController;
}

/// Bootstraps essential dependencies before the UI renders.
Future<AppContainer> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final secureStorage = SecureStorageService();
  final settingsStore = LocalSettingsStore(prefs);
  final historyStorage = HistoryStorageService(prefs);
  final themeController = ThemeModeController(prefs);

  final initialBaseUrl = await settingsStore.getApiBaseUrl();
  final apiClient = ApiClient(baseUrl: initialBaseUrl);
  final healthManager = BackendHealthManager(apiClient: apiClient);

  final composeRepo = ComposeRepository(apiClient);
  final rewriteRepo = RewriteRepository(apiClient);
  final historyRepo = HistoryRepository(historyStorage);

  final settingsController = SettingsController(
    apiClient: apiClient,
    secureStorage: secureStorage,
    settingsStore: settingsStore,
    healthManager: healthManager,
  );

  final composeController = ComposeController(
    repository: composeRepo,
    secureStorage: secureStorage,
    settingsStore: settingsStore,
    historyStorage: historyStorage,
    healthManager: healthManager,
  );

  final rewriteController = RewriteController(
    repository: rewriteRepo,
    secureStorage: secureStorage,
    settingsStore: settingsStore,
    historyStorage: historyStorage,
    healthManager: healthManager,
  );


  final historyController = HistoryController(historyRepo);

  return AppContainer(
    themeController: themeController,
    settingsController: settingsController,
    composeController: composeController,
    rewriteController: rewriteController,
    historyController: historyController,
  );
}
