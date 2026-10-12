import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';

/// Bubble representing a user prompt turn in the conversation flow.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isRefinement = false,
  });

  final String message;
  final bool isRefinement;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: SpacingTokens.md),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: semantic.actionPrimary.withValues(alpha: 0.10),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(ShapeTokens.radiusLg),
            topRight: Radius.circular(ShapeTokens.radiusXs),
            bottomLeft: Radius.circular(ShapeTokens.radiusLg),
            bottomRight: Radius.circular(ShapeTokens.radiusLg),
          ),
          border: Border.all(
            color: semantic.actionPrimary.withValues(alpha: 0.25),
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRefinement ? Icons.auto_fix_normal_rounded : Icons.person_rounded,
                  size: ComponentTokens.iconSizeXs,
                  color: semantic.actionPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  isRefinement ? 'Refinement Request' : 'Goal / Intent',
                  style: textTheme.labelSmall?.copyWith(
                    color: semantic.actionPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: semantic.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
