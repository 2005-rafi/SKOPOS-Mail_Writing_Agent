import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/layout_tokens.dart';
import '../../core/design_system/motion_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/shape_tokens.dart';

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Bottom navigation bar with animated tab selection and accessible touch targets.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<AppNavigationDestination> destinations = [
    AppNavigationDestination(
      label: 'Write',
      icon: Icons.edit_note_rounded,
      selectedIcon: Icons.edit_rounded,
    ),
    AppNavigationDestination(
      label: 'Rewrite',
      icon: Icons.auto_fix_high_rounded,
      selectedIcon: Icons.auto_fix_normal_rounded,
    ),
    AppNavigationDestination(
      label: 'History',
      icon: Icons.history_rounded,
      selectedIcon: Icons.manage_history_rounded,
    ),
    AppNavigationDestination(
      label: 'Settings',
      icon: Icons.tune_rounded,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: LayoutTokens.bottomNavHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: semantic.outlineVariant,
            width: ShapeTokens.borderWidthHairline,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(destinations.length, (index) {
          final dest = destinations[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onDestinationSelected(index),
                child: Center(
                  child: AnimatedContainer(
                    duration: MotionTokens.durationStandard,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? semantic.actionPrimary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: ShapeTokens.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? dest.selectedIcon : dest.icon,
                          size: ComponentTokens.iconSizeMd,
                          color: isSelected ? semantic.actionPrimary : semantic.textMuted,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            dest.label,
                            style: textTheme.labelMedium?.copyWith(
                              color: semantic.actionPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
