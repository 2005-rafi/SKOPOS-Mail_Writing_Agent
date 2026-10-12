import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skopos/app/app.dart';
import 'package:skopos/app/bootstrap.dart';
import 'package:skopos/core/config/app_config.dart';
import 'package:skopos/core/design_system/theme_mode_controller.dart';
import 'package:skopos/core/network/api_client.dart';
import 'package:skopos/core/storage/history_storage_service.dart';
import 'package:skopos/core/storage/local_settings_store.dart';
import 'package:skopos/core/storage/secure_storage_service.dart';
import 'package:skopos/features/compose/data/compose_repository.dart';
import 'package:skopos/features/compose/presentation/compose_controller.dart';
import 'package:skopos/features/history/data/history_repository.dart';
import 'package:skopos/features/history/presentation/history_controller.dart';
import 'package:skopos/features/rewrite/data/rewrite_repository.dart';
import 'package:skopos/features/rewrite/presentation/rewrite_controller.dart';
import 'package:skopos/features/settings/presentation/settings_controller.dart';

void main() {
  testWidgets('SKOPOS App smoke test verifies root scaffold and branding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final secureStorage = SecureStorageService();
    final settingsStore = LocalSettingsStore(prefs);
    final historyStorage = HistoryStorageService(prefs);
    final themeController = ThemeModeController(prefs);
    final apiClient = ApiClient(baseUrl: AppConfig.defaultApiBaseUrl);

    final composeRepo = ComposeRepository(apiClient);
    final rewriteRepo = RewriteRepository(apiClient);
    final historyRepo = HistoryRepository(historyStorage);

    final settingsController = SettingsController(
      apiClient: apiClient,
      secureStorage: secureStorage,
      settingsStore: settingsStore,
    );
    final composeController = ComposeController(
      repository: composeRepo,
      secureStorage: secureStorage,
      settingsStore: settingsStore,
      historyStorage: historyStorage,
    );
    final rewriteController = RewriteController(
      repository: rewriteRepo,
      secureStorage: secureStorage,
      settingsStore: settingsStore,
      historyStorage: historyStorage,
    );
    final historyController = HistoryController(historyRepo);

    final container = AppContainer(
      themeController: themeController,
      settingsController: settingsController,
      composeController: composeController,
      rewriteController: rewriteController,
      historyController: historyController,
    );

    await tester.pumpWidget(SkoposApp(container: container));
    await tester.pumpAndSettle();

    expect(find.text('SKOPOS'), findsOneWidget);
    expect(find.text('Write'), findsOneWidget);
    expect(find.byIcon(Icons.auto_fix_high_rounded), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsNWidgets(2));

    // Tap Rewrite tab and verify label becomes selected
    await tester.tap(find.byIcon(Icons.auto_fix_high_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Rewrite'), findsOneWidget);
  });
}
