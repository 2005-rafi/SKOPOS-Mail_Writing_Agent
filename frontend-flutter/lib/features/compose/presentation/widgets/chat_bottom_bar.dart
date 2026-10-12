import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../shared/widgets/app_bouncy_tap.dart';

/// Pinned bottom composer providing a pure icon-based chat experience
/// with tactile jumping bubble button animations.
class ChatBottomBar extends StatelessWidget {
  const ChatBottomBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onOpenSettings,
    this.hintText = 'Describe what to write, or request changes...',
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onOpenSettings;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final canSend = value.text.trim().isNotEmpty && !isLoading;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: semantic.outlineVariant,
                width: ShapeTokens.borderWidthHairline,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            MediaQuery.of(context).padding.bottom + SpacingTokens.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. Pure Icon Options / Settings Trigger
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: AppBouncyTap(
                  onTap: onOpenSettings,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: semantic.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: semantic.outlineVariant,
                        width: ShapeTokens.borderWidthHairline,
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: ComponentTokens.iconSizeMd,
                      color: semantic.actionPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),

              // 2. Multi-line Message Input Pill
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(ShapeTokens.radiusLg),
                    border: Border.all(
                      color: semantic.outlineVariant,
                      width: ShapeTokens.borderWidthHairline,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (canSend) onSend();
                    },
                    style: textTheme.bodyMedium?.copyWith(
                      color: semantic.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: textTheme.bodySmall?.copyWith(
                        color: semantic.textMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),

              // 3. Pure Icon Jumping Send Bubble Button
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: AppBouncyTap(
                  enabled: canSend,
                  onTap: canSend ? onSend : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: canSend
                          ? semantic.actionPrimary
                          : semantic.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      boxShadow: canSend
                          ? [
                              BoxShadow(
                                color: semantic.actionPrimary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: semantic.onActionPrimary,
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              size: ComponentTokens.iconSizeMd,
                              color: canSend
                                  ? semantic.onActionPrimary
                                  : semantic.textMuted,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
