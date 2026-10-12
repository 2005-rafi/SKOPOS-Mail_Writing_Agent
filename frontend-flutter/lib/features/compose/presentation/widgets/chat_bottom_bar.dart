import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../shared/widgets/app_bouncy_tap.dart';

/// Pinned bottom composer providing a strictly aligned, dual-color architecture chat interface.
/// Includes a bounded elastic input capsule (44px min, 5 lines max, scrollable beyond),
/// character limitation with auxiliary micro-counter, and format switcher badge above send button.
class ChatBottomBar extends StatefulWidget {
  const ChatBottomBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onOpenSettings,
    required this.contentType,
    required this.onContentTypeChanged,
    this.hintText = 'Describe what to write, or request changes...',
    this.maxCharacters = 1500,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onOpenSettings;
  final String contentType;
  final ValueChanged<String> onContentTypeChanged;
  final String hintText;
  final int maxCharacters;

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    final isEmail = widget.contentType == 'email';

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final currentLength = value.text.length;
        final canSend = value.text.trim().isNotEmpty && !widget.isLoading;

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
            SpacingTokens.xs + 2.0,
            SpacingTokens.md,
            MediaQuery.of(context).padding.bottom + SpacingTokens.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Auxiliary Bar: Humanized Mode + Micro Character Counter (Left) + Mail/Letter Switcher Badge (Right)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mode Label + Character Count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: semantic.actionPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          isEmail ? 'Email Communication' : 'Formal Letter Format',
                          style: textTheme.labelSmall?.copyWith(
                            color: semantic.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (currentLength > 0) ...[
                          const SizedBox(width: SpacingTokens.xs),
                          Text(
                            '• $currentLength/${widget.maxCharacters}',
                            style: textTheme.labelSmall?.copyWith(
                              color: currentLength >= (widget.maxCharacters - 100)
                                  ? semantic.statusWarning
                                  : semantic.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Small Mail vs. Letter Badge positioned directly above the send button
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: semantic.surfaceContainer,
                        borderRadius: BorderRadius.circular(ShapeTokens.radiusFull),
                        border: Border.all(
                          color: semantic.outlineVariant,
                          width: ShapeTokens.borderWidthHairline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mail Option
                          AppBouncyTap(
                            onTap: () => widget.onContentTypeChanged('email'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isEmail ? semantic.actionPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(ShapeTokens.radiusFull),
                                boxShadow: isEmail
                                    ? [
                                        BoxShadow(
                                          color: semantic.actionPrimary.withValues(alpha: 0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Tooltip(
                                message: 'Write Email',
                                child: Icon(
                                  Icons.mail_rounded,
                                  size: 15,
                                  color: isEmail ? semantic.onActionPrimary : semantic.textMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),

                          // Letter Option
                          AppBouncyTap(
                            onTap: () => widget.onContentTypeChanged('letter'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !isEmail ? semantic.actionPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(ShapeTokens.radiusFull),
                                boxShadow: !isEmail
                                    ? [
                                        BoxShadow(
                                          color: semantic.actionPrimary.withValues(alpha: 0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Tooltip(
                                message: 'Write Letter',
                                child: Icon(
                                  Icons.description_rounded,
                                  size: 15,
                                  color: !isEmail ? semantic.onActionPrimary : semantic.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Composer Row: [ Settings Button (44) ] [ Bounded Input Capsule ] [ Send Bubble (44) ]
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Settings / Options Trigger
                  AppBouncyTap(
                    onTap: widget.onOpenSettings,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: semantic.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: semantic.outlineVariant,
                          width: ShapeTokens.borderWidthHairline,
                        ),
                      ),
                      child: Tooltip(
                        message: 'Writing Settings',
                        child: Icon(
                          Icons.tune_rounded,
                          size: ComponentTokens.iconSizeMd,
                          color: semantic.actionPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),

                  // Bounded Elastic Input Capsule (44px min, 5 lines max, scrollable beyond)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      constraints: const BoxConstraints(minHeight: 44.0),
                      decoration: BoxDecoration(
                        color: semantic.surfaceContainer,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _isFocused
                              ? semantic.actionPrimary.withValues(alpha: 0.65)
                              : semantic.outlineVariant,
                          width: _isFocused ? 1.5 : ShapeTokens.borderWidthHairline,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: widget.maxCharacters,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                        scrollPhysics: const BouncingScrollPhysics(),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (canSend) widget.onSend();
                        },
                        style: textTheme.bodyMedium?.copyWith(
                          color: semantic.textPrimary,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: textTheme.bodySmall?.copyWith(
                            color: semantic.textMuted,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),

                  // Jumping Bubble Send Button
                  AppBouncyTap(
                    enabled: canSend,
                    onTap: canSend ? widget.onSend : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: 44,
                      height: 44,
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
                        child: widget.isLoading
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
