import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';
import '../../core/design_system/spacing_tokens.dart';

class AppDropdownOption<T> {
  const AppDropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.description,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? description;
}

/// Generic, accessible dropdown component using design system tokens.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.label,
    this.hint,
    this.enabled = true,
  });

  final List<AppDropdownOption<T>> items;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.labelMedium?.copyWith(
              color: semantic.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
        ],
        Container(
          height: ComponentTokens.inputHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ShapeTokens.borderRadiusMd,
            border: Border.all(
              color: semantic.outline,
              width: ShapeTokens.borderWidthHairline,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selectedValue,
              isExpanded: true,
              hint: hint != null
                  ? Text(
                      hint!,
                      style: textTheme.bodyMedium?.copyWith(color: semantic.textMuted),
                    )
                  : null,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? semantic.textSecondary : semantic.textMuted,
                size: ComponentTokens.iconSizeMd,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(item.icon, size: ComponentTokens.iconSizeSm, color: semantic.actionPrimary),
                        const SizedBox(width: SpacingTokens.sm),
                      ],
                      Expanded(
                        child: Text(
                          item.label,
                          style: textTheme.bodyMedium?.copyWith(color: semantic.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: ShapeTokens.borderRadiusMd,
            ),
          ),
        ),
      ],
    );
  }
}
