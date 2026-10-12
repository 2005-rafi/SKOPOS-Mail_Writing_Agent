import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Bottom card for conversational refinement instructions.
class RefinementBar extends StatelessWidget {
  const RefinementBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onRefine,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onRefine;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: ComponentTokens.iconSizeMd,
                color: semantic.actionPrimary,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Conversational Refinement',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: semantic.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller,
                  hint: 'e.g., Make it firmer, shorten the 2nd paragraph, set deadline to 5 PM...',
                  onSubmitted: (_) => onRefine(),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: AppButton(
                  text: 'Refine',
                  isLoading: isLoading,
                  onPressed: onRefine,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
