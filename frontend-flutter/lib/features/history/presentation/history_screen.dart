import 'package:flutter/material.dart';
import '../../../core/design_system/component_tokens.dart';
import '../../../core/design_system/layout_tokens.dart';
import '../../../core/design_system/spacing_tokens.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_segmented_control.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../compose/domain/compose_models.dart';
import '../domain/history_item.dart';
import 'history_controller.dart';
import 'widgets/history_detail_sheet.dart';
import 'widgets/history_item_card.dart';

/// Screen displaying searchable offline generation history with load and copy capabilities.
/// Adheres to minimalist design with dynamic segmented filter controls.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.controller,
    required this.onLoadIntoCompose,
  });

  final HistoryController controller;
  final ValueChanged<GenerateResponse> onLoadIntoCompose;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will permanently delete all local generated communications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Clear All',
            variant: AppButtonVariant.destructive,
            onPressed: () {
              widget.controller.clearHistory();
              Navigator.of(ctx).pop();
              AppSnackbar.show(
                context,
                message: 'Local history cleared',
                type: AppSnackbarType.info,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(HistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryDetailSheet(
        item: item,
        onLoadIntoCompose: widget.onLoadIntoCompose,
        onDelete: () {
          widget.controller.deleteItem(item.id);
          AppSnackbar.show(
            context,
            message: 'Document deleted',
            type: AppSnackbarType.info,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final items = widget.controller.items;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LayoutTokens.maxContentWidth),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _searchController,
                              hint: 'Search saved emails, letters, keywords...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: ComponentTokens.iconSizeSm),
                                      onPressed: () {
                                        _searchController.clear();
                                        widget.controller.search('');
                                      },
                                    )
                                  : null,
                              onChanged: (val) => widget.controller.search(val),
                            ),
                          ),
                          if (widget.controller.totalCount > 0) ...[
                            const SizedBox(width: SpacingTokens.sm),
                            AppIconButton(
                              icon: Icons.delete_sweep_rounded,
                              tooltip: 'Clear All History',
                              onPressed: _showClearConfirmDialog,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),

                      // Sleek Animated Segmented Filter
                      AppSegmentedControl<String>(
                        options: const [
                          SegmentOption(
                            value: 'all',
                            label: 'All Documents',
                            icon: Icons.folder_open_rounded,
                          ),
                          SegmentOption(
                            value: 'email',
                            label: 'Emails',
                            icon: Icons.mail_outline_rounded,
                          ),
                          SegmentOption(
                            value: 'letter',
                            label: 'Letters',
                            icon: Icons.description_outlined,
                          ),
                        ],
                        selectedValue: widget.controller.selectedType,
                        onSelected: (typeKey) => widget.controller.setTypeFilter(typeKey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const AppEmptyState(
                          title: 'No documents found',
                          description: 'Generated and rewritten communications are automatically saved here offline.',
                          icon: Icons.history_edu_rounded,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.lg,
                            vertical: SpacingTokens.xs,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: SpacingTokens.sm),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return HistoryItemCard(
                              item: item,
                              onTap: () => _showDetailSheet(item),
                              onDelete: () {
                                widget.controller.deleteItem(item.id);
                                AppSnackbar.show(
                                  context,
                                  message: 'Document deleted',
                                  type: AppSnackbarType.info,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
