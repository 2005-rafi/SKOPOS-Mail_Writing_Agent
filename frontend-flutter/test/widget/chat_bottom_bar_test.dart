import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/design_system/app_theme.dart';
import 'package:skopos/features/compose/presentation/widgets/chat_bottom_bar.dart';

void main() {
  group('ChatBottomBar Widget Tests', () {
    testWidgets('Renders aligned components, mail/letter switcher, and fires callback on change', (tester) async {
      final controller = TextEditingController();
      String selectedType = 'email';
      bool sent = false;
      bool settingsOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ChatBottomBar(
                  controller: controller,
                  isLoading: false,
                  contentType: selectedType,
                  onContentTypeChanged: (newType) {
                    setState(() {
                      selectedType = newType;
                    });
                  },
                  onSend: () {
                    sent = true;
                  },
                  onOpenSettings: () {
                    settingsOpened = true;
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify Mail icon and Letter icon exist in the switcher badge
      expect(find.byIcon(Icons.mail_rounded), findsOneWidget);
      expect(find.byIcon(Icons.description_rounded), findsOneWidget);
      expect(find.text('Email Communication'), findsOneWidget);

      // Verify Settings button exists
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      // Tap settings button
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(settingsOpened, isTrue);

      // Tap Letter icon in the badge
      await tester.tap(find.byIcon(Icons.description_rounded));
      await tester.pumpAndSettle();
      expect(selectedType, 'letter');
      expect(find.text('Formal Letter Format'), findsOneWidget);

      // Type text and verify character counter and send button enables
      await tester.enterText(find.byType(TextField), 'Test prompt scenario');
      await tester.pumpAndSettle();
      expect(find.text('• 20/1500'), findsOneWidget);

      // Tap send button
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();
      expect(sent, isTrue);
    });
  });
}
