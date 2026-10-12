import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/features/compose/domain/compose_models.dart';
import 'package:skopos/features/history/domain/history_item.dart';


void main() {
  group('Model Serialization Tests', () {
    test('OutputContent JSON roundtrip parses subject, salutation, body, closing', () {
      final json = {
        'subject': 'Order Delayed',
        'salutation': 'Dear Customer,',
        'body': 'Your order has been delayed by 2 days.',
        'closing': 'Sincerely,\nSupport Team',
      };

      final model = OutputContent.fromJson(json);
      expect(model.subject, equals('Order Delayed'));
      expect(model.salutation, equals('Dear Customer,'));
      expect(model.body, equals('Your order has been delayed by 2 days.'));
      expect(model.closing, equals('Sincerely,\nSupport Team'));

      final serialized = model.toJson();
      expect(serialized['subject'], equals('Order Delayed'));
      expect(serialized['body'], equals('Your order has been delayed by 2 days.'));
    });

    test('SettingsModel defaults and copyWith function properly', () {
      const defaultSettings = SettingsModel();
      expect(defaultSettings.tone, equals('professional'));
      expect(defaultSettings.maxWords, equals(150));
      expect(defaultSettings.subjectEnabled, isTrue);

      final updated = defaultSettings.copyWith(
        tone: 'custom',
        customTone: 'Polite yet resolute',
        style: 'custom',
        customStyle: 'Executive BLUF format',
        maxWords: 200,
        subjectEnabled: false,
      );
      expect(updated.tone, equals('custom'));
      expect(updated.customTone, equals('Polite yet resolute'));
      expect(updated.style, equals('custom'));
      expect(updated.customStyle, equals('Executive BLUF format'));
      expect(updated.maxWords, equals(200));
      expect(updated.subjectEnabled, isFalse);

      final json = updated.toJson();
      final roundtrip = SettingsModel.fromJson(json);
      expect(roundtrip.customTone, equals('Polite yet resolute'));
      expect(roundtrip.customStyle, equals('Executive BLUF format'));
    });

    test('HistoryItem serializes and deserializes according to PRD Section 22 data model', () {
      final json = {
        'id': 'hist-uuid-001',
        'type': 'letter',
        'scenario': 'Customer formal complaint regarding raw material delivery delay.',
        'output': {
          'subject': 'Notice of Contract Breach',
          'salutation': 'Dear Sir/Madam,',
          'body': 'We hereby give notice of formal complaint.',
          'closing': 'Yours faithfully,\nOperations Director',
        },
        'settings': {
          'tone': 'custom',
          'customTone': 'Strict legal warning',
          'style': 'formal',
          'language': 'English',
          'subjectEnabled': true,
          'salutationEnabled': true,
          'closingEnabled': true,
          'maxWords': 250,
        },
        'provider': 'gemini',
        'model': 'gemini-1.5-pro',
        'createdAt': '2026-10-12T10:00:00Z',
        'updatedAt': '2026-10-12T10:00:05Z',
        'wordCount': 120,
      };

      final item = HistoryItem.fromJson(json);
      expect(item.id, equals('hist-uuid-001'));
      expect(item.type, equals('letter'));
      expect(item.scenario, contains('Customer formal complaint'));
      expect(item.settings.customTone, equals('Strict legal warning'));
      expect(item.updatedAt, equals('2026-10-12T10:00:05Z'));

      final serialized = item.toJson();
      expect(serialized['id'], equals('hist-uuid-001'));
      expect(serialized['scenario'], equals(item.scenario));
      expect(serialized['settings']['customTone'], equals('Strict legal warning'));
    });

    test('GenerateResponse parses validation summary and metadata', () {

      final json = {
        'id': 'gen-101',
        'type': 'email',
        'output': {
          'subject': 'Urgent notice',
          'salutation': 'Hello,',
          'body': 'Please review the attached contract.',
          'closing': 'Best regards',
        },
        'settings': {
          'tone': 'formal',
          'language': 'English',
        },
        'provider': 'groq',
        'model': 'llama-3.3-70b-versatile',
        'wordCount': 55,
        'validation': {
          'passed': true,
          'repaired': false,
          'issues': [],
        },
        'createdAt': '2026-10-11T20:00:00Z',
      };

      final response = GenerateResponse.fromJson(json);
      expect(response.id, equals('gen-101'));
      expect(response.provider, equals('groq'));
      expect(response.wordCount, equals(55));
      expect(response.validation.passed, isTrue);
      expect(response.output.body, equals('Please review the attached contract.'));
    });
  });
}
