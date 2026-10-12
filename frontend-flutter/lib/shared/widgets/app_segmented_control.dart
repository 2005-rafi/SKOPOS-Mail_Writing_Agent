import 'package:flutter/material.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';

/// Data model representing a single segment option.
class SegmentOption<T> {
  const SegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Dynamic, minimalist segmented control supporting generic type values.
/// Renders an understated background track with animated active indicator.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.isFullWidth = true,
  });

  final List<SegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    final control = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: semantic.surfaceContainerHigh,
        borderRadius: ShapeTokens.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option.value == selectedValue;

          final segmentItem = AnimatedContainer(
            duration: MotionTokens.durationStandard,
            curve: MotionTokens.curveStandard,
            decoration: BoxDecoration(
              color: isSelected ? semantic.actionPrimary : Colors.transparent,
              borderRadius: ShapeTokens.borderRadiusSm,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: semantic.actionPrimary.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(option.value),
                borderRadius: ShapeTokens.borderRadiusSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: 15,
                          color: isSelected
                              ? semantic.onActionPrimary
                              : semantic.textSecondary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? semantic.onActionPrimary
                              : semantic.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          return isFullWidth ? Expanded(child: segmentItem) : segmentItem;
        }).toList(),
      ),
    );

    return control;
  }
}
