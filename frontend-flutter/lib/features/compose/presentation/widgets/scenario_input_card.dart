import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_area.dart';

/// Card containing the primary scenario prompt input and generation button.
class ScenarioInputCard extends StatelessWidget {
  const ScenarioInputCard({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onGenerate,
    required this.onOpenSettings,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onGenerate;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.create_rounded,
                    size: ComponentTokens.iconSizeMd,
                    color: semantic.actionPrimary,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Situation / Intent',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: semantic.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onOpenSettings,
                icon: Icon(
                  Icons.tune_rounded,
                  size: ComponentTokens.iconSizeSm,
                  color: semantic.actionPrimary,
                ),
                label: Text(
                  'Options',
                  style: textTheme.labelMedium?.copyWith(
                    color: semantic.actionPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          AppTextArea(
            controller: controller,
            hint: 'e.g., Client shipment order #104 is delayed by 3 days. Apologize professionally and offer expedited courier delivery.',
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: SpacingTokens.md),
          AppButton(
            text: 'Generate Communication',
            leadingIcon: Icons.auto_awesome_rounded,
            isLoading: isLoading,
            isFullWidth: true,
            onPressed: onGenerate,
          ),
        ],
      ),
    );
  }
}
