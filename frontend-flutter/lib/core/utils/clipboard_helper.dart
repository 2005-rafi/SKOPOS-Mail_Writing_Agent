import 'package:flutter/services.dart';

/// Helper for safe clipboard operations without raw HTML/markdown leakage.
abstract class ClipboardHelper {
  static Future<bool> copyPlainText(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return false;
    try {
      await Clipboard.setData(ClipboardData(text: clean));
      return true;
    } catch (_) {
      return false;
    }
  }
}
