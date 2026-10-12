import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/design_system/app_theme.dart';
import 'package:skopos/shared/widgets/app_text_field.dart';

void main() {
  group('AppTextField Widget Tests', () {
    testWidgets('Renders label, hint, and accepts user text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              label: 'Groq API Key',
              hint: 'gsk_...',
            ),
          ),
        ),
      );

      expect(find.text('Groq API Key'), findsOneWidget);
      expect(find.text('gsk_...'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'gsk_test_123456');
      expect(controller.text, equals('gsk_test_123456'));
    });

    testWidgets('Renders errorText when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppTextField(
              label: 'Provider Key',
              errorText: 'Key is required',
            ),
          ),
        ),
      );

      expect(find.text('Key is required'), findsOneWidget);
    });
  });
}
