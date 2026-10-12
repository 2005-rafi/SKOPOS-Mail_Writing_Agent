import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/design_system/app_theme.dart';
import 'package:skopos/features/compose/domain/compose_models.dart';
import 'package:skopos/shared/widgets/app_bouncy_tap.dart';
import 'package:skopos/shared/widgets/app_dropdown.dart';
import 'package:skopos/shared/widgets/app_segmented_control.dart';
import 'package:skopos/shared/widgets/settings_group.dart';
import 'package:skopos/shared/widgets/writing_preferences_editor.dart';

void main() {
  group('Reusable Components Tests', () {
    testWidgets('AppSegmentedControl renders options and invokes onSelected callback', (tester) async {
      String selected = 'email';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppSegmentedControl<String>(
                  options: const [
                    SegmentOption(
                      value: 'email',
                      label: 'Email',
                      icon: Icons.mail_outline_rounded,
                    ),
                    SegmentOption(
                      value: 'letter',
                      label: 'Letter',
                      icon: Icons.description_outlined,
                    ),
                  ],
                  selectedValue: selected,
                  onSelected: (val) {
                    setState(() => selected = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Letter'), findsOneWidget);

      // Tap Letter
      await tester.tap(find.text('Letter'));
      await tester.pumpAndSettle();

      expect(selected, equals('letter'));
    });

    testWidgets('SettingsGroup renders header title, icon, and enclosed children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SettingsGroup(
              title: 'Account Settings',
              icon: Icons.person_outline_rounded,
              children: [
                Text('User Profile Item'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text('User Profile Item'), findsOneWidget);
    });

    testWidgets('WritingPreferencesEditor renders dropdowns and dynamically expands custom tone input', (tester) async {
      SettingsModel currentSettings = const SettingsModel(
        tone: 'professional',
        style: 'concise',
        maxWords: 150,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: WritingPreferencesEditor(
                    settings: currentSettings,
                    onChanged: (updated) {
                      setState(() => currentSettings = updated);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initial state: custom tone input should NOT be present
      expect(find.text('Describe Your Specific Tone'), findsNothing);

      // Select "Other / Custom Tone..." from dropdown
      await tester.tap(find.text('Professional'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Other / Custom Tone...').last);
      await tester.pumpAndSettle();

      // Dynamic expansion: custom tone input now exists
      expect(find.text('Describe Your Specific Tone'), findsOneWidget);
      expect(currentSettings.tone, equals('custom'));
    });

    testWidgets('AppBouncyTap renders child and fires onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppBouncyTap(
                onTap: () => tapped = true,
                child: const Text('Bouncy Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bouncy Button'), findsOneWidget);
      await tester.tap(find.text('Bouncy Button'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AppDropdown safely falls back when selectedValue does not match any item', (tester) async {
      String? selectedValue = 'llama3-8b-8192'; // Stale Groq model

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppDropdown<String>(
                  label: 'Model Selection',
                  selectedValue: selectedValue,
                  items: const [
                    AppDropdownOption(value: 'gemini-1.5-flash', label: 'Gemini 1.5 Flash'),
                    AppDropdownOption(value: 'gemini-1.5-pro', label: 'Gemini 1.5 Pro'),
                  ],
                  onChanged: (val) {
                    setState(() => selectedValue = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Should not throw Flutter assertion error and should display the first available item as effective fallback
      expect(find.text('Gemini 1.5 Flash'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
