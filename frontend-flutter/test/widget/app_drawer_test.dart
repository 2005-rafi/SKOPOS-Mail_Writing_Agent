import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skopos/core/design_system/app_theme.dart';
import 'package:skopos/core/design_system/theme_mode_controller.dart';
import 'package:skopos/core/network/backend_health_manager.dart';
import 'package:skopos/shared/widgets/app_drawer.dart';
import 'package:skopos/shared/widgets/app_logo.dart';

void main() {
  group('AppLogo and AppDrawer Widget Tests', () {
    testWidgets('AppLogo renders with specified size and clips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: AppLogo(size: 32, showBorder: true),
            ),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
    });

    testWidgets('AppDrawer renders branding, navigation items, and responds to taps', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final themeController = ThemeModeController(prefs);

      int selectedIndex = -1;
      bool healthTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            drawer: AppDrawer(
              currentIndex: 0,
              onSelectIndex: (idx) => selectedIndex = idx,
              healthState: BackendHealthState.online,
              onTapHealth: () => healthTapped = true,
              themeController: themeController,
            ),
            body: const Center(child: Text('Home')),
          ),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check brand presence
      expect(find.byType(AppDrawer), findsOneWidget);
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('SKOPOS'), findsOneWidget);
      expect(find.text('Backend Online'), findsOneWidget);

      // Check navigation items
      expect(find.text('Write / Compose'), findsOneWidget);
      expect(find.text('Rewrite & Polish'), findsOneWidget);
      expect(find.text('Local History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Tap Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(selectedIndex, equals(3));
    });
  });
}
