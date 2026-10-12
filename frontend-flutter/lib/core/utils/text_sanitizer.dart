/// Utility to sanitize raw LLM outputs and extract structured paragraphs.
abstract class TextSanitizer {
  /// Strips raw HTML break tags (<br>, <br/>, <p>) and normalizes line endings.
  static String sanitize(String text) {
    if (text.isEmpty) return '';

    var clean = text;
    // Replace <br>, <br/>, <br /> (case-insensitive)
    clean = clean.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    clean = clean.replaceAll(RegExp(r'</?p\s*>', caseSensitive: false), '\n\n');
    clean = clean.replaceAll('&lt;br&gt;', '\n');
    clean = clean.replaceAll('&lt;br/&gt;', '\n');

    // Normalize Windows CRLF and CR
    clean = clean.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Collapse multiple consecutive blank lines
    clean = clean.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return clean.trim();
  }

  /// Splits sanitized text into individual paragraph blocks.
  static List<String> extractParagraphs(String text) {
    final sanitized = sanitize(text);
    if (sanitized.isEmpty) return [];

    return sanitized
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// Strips Markdown formatting markers to extract pristine plaintext for clipboard.
  static String toPlainText(String text) {
    var str = sanitize(text);

    // Strip code fence markers
    str = str.replaceAllMapped(
      RegExp(r'```[a-zA-Z0-9_-]*\n([\s\S]*?)```'),
      (m) => m[1] ?? '',
    );

    // Strip inline markdown markers
    str = str.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m[1] ?? '');
    str = str.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m[1] ?? '');
    str = str.replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m[1] ?? '');
    str = str.replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m[1] ?? '');
    str = str.replaceAllMapped(RegExp(r'_([^_]+)_'), (m) => m[1] ?? '');
    str = str.replaceAllMapped(RegExp(r'~~([^~]+)~~'), (m) => m[1] ?? '');

    return str.trim();
  }
}
