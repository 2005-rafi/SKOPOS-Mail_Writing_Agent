import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/design_system/app_theme.dart';
import 'package:skopos/shared/widgets/app_button.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('Renders label and handles tap event when enabled', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              text: 'Generate Communication',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Generate Communication'), findsOneWidget);
      await tester.tap(find.text('Generate Communication'));
      expect(tapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator and ignores taps when isLoading is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              text: 'Save Options',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save Options'), findsNothing);

      await tester.tap(find.byType(CircularProgressIndicator));
      expect(tapped, isFalse);
    });
  });
}
