import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/utils/text_sanitizer.dart';

void main() {
  group('TextSanitizer Tests', () {
    test('Cleans raw HTML <br>, <br/> and entity breaks into standard newlines', () {
      const input = 'Line 1<br>Line 2<br/>Line 3<BR />Line 4&lt;br&gt;Line 5';
      final cleaned = TextSanitizer.sanitize(input);
      expect(cleaned, equals('Line 1\nLine 2\nLine 3\nLine 4\nLine 5'));
    });

    test('Collapses excessive blank lines into double newlines', () {
      const input = 'Paragraph 1\n\n\n\nParagraph 2';
      final cleaned = TextSanitizer.sanitize(input);
      expect(cleaned, equals('Paragraph 1\n\nParagraph 2'));
    });

    test('Splits text into clean individual paragraphs', () {
      const input = 'Dear Customer,<br><br>First paragraph of the email.<br><br>Second paragraph with details.';
      final paragraphs = TextSanitizer.extractParagraphs(input);
      expect(paragraphs.length, equals(3));
      expect(paragraphs[0], equals('Dear Customer,'));
      expect(paragraphs[1], equals('First paragraph of the email.'));
      expect(paragraphs[2], equals('Second paragraph with details.'));
    });

    test('Extracts pristine plaintext without markdown asterisks or code fences', () {
      const input = '**Important:** Review `order #402` details.\n```code\nitem: 1\n```';
      final plain = TextSanitizer.toPlainText(input);
      expect(plain, contains('Important: Review order #402 details.'));
      expect(plain, isNot(contains('**')));
      expect(plain, isNot(contains('`')));
    });
  });
}
