import 'package:flutter/material.dart';
import '../../../core/design_system/component_tokens.dart';
import '../../../core/design_system/layout_tokens.dart';
import '../../../core/design_system/semantic_colors.dart';
import '../../../core/design_system/shape_tokens.dart';
import '../../../core/design_system/spacing_tokens.dart';
import '../../../shared/widgets/app_bouncy_tap.dart';
import '../../../shared/widgets/app_snackbar.dart';

import 'compose_controller.dart';
import 'widgets/chat_bottom_bar.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/compose_idle_view.dart';
import 'widgets/generated_output_card.dart';

/// Screen providing a unified, pure icon-based conversational interface
/// for generating and refining communications.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    super.key,
    required this.controller,
    this.onNavigateToSettings,
  });

  final ComposeController controller;
  final VoidCallback? onNavigateToSettings;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final isRefinement = widget.controller.currentOutput != null;
    _messageController.clear();

    final bool success;
    if (isRefinement) {
      success = await widget.controller.refine(text);
      if (success && mounted) {
        _scrollToBottom();
      }
    } else {
      success = await widget.controller.generate(text);
      if (success && mounted) {
        _scrollToBottom();
      }
    }

    if (!success && mounted && widget.controller.errorMessage != null) {
      AppSnackbar.show(
        context,
        message: widget.controller.errorMessage!,
        type: AppSnackbarType.error,
      );
    }
  }

  void _handleSelectStarter(String prompt) {
    _messageController.text = prompt;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: prompt.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final currentOutput = widget.controller.currentOutput;
        final isLoading = widget.controller.isLoading;
        final isIdle = currentOutput == null && !isLoading && widget.controller.chatTurns.isEmpty;

        return Column(
          children: [
            // 1. Conversation / Idle Viewport
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: LayoutTokens.maxContentWidth),
                  child: isIdle
                      ? ComposeIdleView(
                          onSelectStarter: _handleSelectStarter,
                        )
                      : ListView(
                          controller: _scrollController,
                          padding: SpacingTokens.screenPadding,
                          children: [
                            // Conversation Header Row with Pure Icon Reset/New Chat
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Conversation',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: semantic.textMuted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                AppBouncyTap(
                                  onTap: widget.controller.resetChat,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: SpacingTokens.sm,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: semantic.surfaceContainer,
                                      borderRadius: ShapeTokens.borderRadiusFull,
                                      border: Border.all(
                                        color: semantic.outlineVariant,
                                        width: ShapeTokens.borderWidthHairline,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          size: ComponentTokens.iconSizeXs,
                                          color: semantic.actionPrimary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'New Draft',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: semantic.actionPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpacingTokens.md),

                            // Chat Turns (User Prompts and Refinements)
                            for (final turn in widget.controller.chatTurns)
                              ChatMessageBubble(
                                message: turn['text'] as String,
                                isRefinement: turn['type'] == 'user_refine',
                              ),

                            // Generated Output Card
                            if (currentOutput != null) ...[
                              GeneratedOutputCard(response: currentOutput),
                              const SizedBox(height: SpacingTokens.md),
                            ],

                            // Loading State
                            if (isLoading) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpacingTokens.md,
                                    vertical: SpacingTokens.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: semantic.surfaceContainer,
                                    borderRadius: BorderRadius.circular(ShapeTokens.radiusLg),
                                    border: Border.all(
                                      color: semantic.outlineVariant,
                                      width: ShapeTokens.borderWidthHairline,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: semantic.actionPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: SpacingTokens.sm),
                                      Text(
                                        widget.controller.state == ComposeState.generating
                                            ? 'Crafting your communication...'
                                            : 'Refining your draft...',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: semantic.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.md),
                            ],
                          ],
                        ),
                ),
              ),
            ),

            // 2. Pinned Bottom Chat Message Box
            ChatBottomBar(
              controller: _messageController,
              isLoading: isLoading,
              onSend: _handleSend,
              onOpenSettings: widget.onNavigateToSettings ?? () {},
              hintText: currentOutput == null
                  ? 'Describe what you need written...'
                  : 'Request changes or refinements...',
            ),
          ],
        );
      },
    );
  }
}
