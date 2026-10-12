import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/design_system/color_tokens.dart';
import 'package:skopos/core/design_system/semantic_colors.dart';
import 'package:skopos/core/design_system/spacing_tokens.dart';

void main() {
  group('Design Tokens Tests', () {
    test('Brand palette anchors match Moon Garden and Crimson Orchid specs', () {
      expect(ColorTokens.moonGarden.toARGB32(), equals(0xFFE7F2E4));
      expect(ColorTokens.crimsonOrchid.toARGB32(), equals(0xFF732255));
    });

    test('SemanticColors light and dark variants are non-null and distinct', () {
      const light = SemanticColors.light;
      const dark = SemanticColors.dark;

      expect(light.actionPrimary, equals(ColorTokens.crimsonOrchid));
      expect(dark.actionPrimary, isNot(equals(light.actionPrimary)));
      expect(light.textPrimary, isNot(equals(dark.textPrimary)));
    });

    test('Spacing tokens adhere to 4px rhythm', () {
      expect(SpacingTokens.xs % 4, equals(0));
      expect(SpacingTokens.sm % 4, equals(0));
      expect(SpacingTokens.md % 4, equals(0));
      expect(SpacingTokens.lg % 4, equals(0));
      expect(SpacingTokens.xl % 4, equals(0));
    });
  });
}
