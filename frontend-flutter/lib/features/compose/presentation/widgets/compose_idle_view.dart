import 'package:flutter/material.dart';
import '../../../../core/design_system/component_tokens.dart';
import '../../../../core/design_system/semantic_colors.dart';
import '../../../../core/design_system/shape_tokens.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../shared/widgets/app_bouncy_tap.dart';
import '../../../../shared/widgets/app_logo.dart';

/// Human-touch idle presentation screen displayed when no generation is active.
class ComposeIdleView extends StatelessWidget {
  const ComposeIdleView({
    super.key,
    required this.onSelectStarter,
  });

  final ValueChanged<String> onSelectStarter;

  static const List<Map<String, dynamic>> _starters = [
    {
      'icon': Icons.schedule_rounded,
      'label': 'Apologize for delay',
      'prompt': 'Client shipment order #104 is delayed by 3 days. Apologize professionally and offer expedited courier delivery.',
    },
    {
      'icon': Icons.mail_outline_rounded,
      'label': 'Follow up on proposal',
      'prompt': 'Follow up politely on the design proposal sent last Tuesday, asking if there are any questions before finalizing.',
    },
    {
      'icon': Icons.event_repeat_rounded,
      'label': 'Reschedule meeting',
      'prompt': 'Request to reschedule tomorrow\'s product review meeting due to an urgent scheduling conflict, proposing two alternate times.',
    },
    {
      'icon': Icons.celebration_outlined,
      'label': 'Thank the team',
      'prompt': 'Congratulate and thank the team for successfully launching the Q3 deliverable ahead of schedule.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppLogo(
              size: 72,
              showBorder: true,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'What would you like to write today?',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: semantic.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                'Whether it is a delicate apology, a project proposal, or a quick note, describe your goal below and SKOPOS will craft your words with precision.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: semantic.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.sm,
              alignment: WrapAlignment.center,
              children: _starters.map((starter) {
                return AppBouncyTap(
                  onTap: () => onSelectStarter(starter['prompt'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
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
                          starter['icon'] as IconData,
                          size: ComponentTokens.iconSizeSm,
                          color: semantic.actionPrimary,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          starter['label'] as String,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: semantic.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
