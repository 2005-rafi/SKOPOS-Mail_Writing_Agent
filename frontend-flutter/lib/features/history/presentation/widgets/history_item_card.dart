import 'package:flutter/material.dart';
import '../../../../core/design_system/spacing_tokens.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/history_item.dart';

/// Clean, minimalist history item card tile.
/// Extracts inline list item rendering out of HistoryScreen for modular reusability.
class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subject = item.output.subject ?? 'Untitled Communication';
    final snippet = TextSanitizer.toPlainText(item.output.body);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppBadge(
                    label: item.type.toUpperCase(),
                    variant: item.type == 'email'
                        ? AppBadgeVariant.brand
                        : AppBadgeVariant.neutral,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  AppBadge(
                    label: item.provider.toUpperCase(),
                    variant: AppBadgeVariant.neutral,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    item.createdAt.length >= 10
                        ? item.createdAt.substring(0, 10)
                        : item.createdAt,
                    style: textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    tooltip: 'Delete item',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            subject,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            snippet,
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.scenario != null && item.scenario!.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'Scenario: ${item.scenario}',
              style: textTheme.labelSmall?.copyWith(
                color: Theme.of(context).hintColor,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
