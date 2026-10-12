import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skopos/core/design_system/theme_mode_controller.dart';

void main() {
  group('ThemeModeController Tests', () {
    test('Defaults to ThemeMode.system and updates to light and dark', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final controller = ThemeModeController(prefs);
      expect(controller.themeMode, equals(ThemeMode.system));
      expect(controller.isDarkMode, isFalse);

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, equals(ThemeMode.dark));
      expect(controller.isDarkMode, isTrue);

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, equals(ThemeMode.light));
      expect(controller.isDarkMode, isFalse);
    });
  });
}
