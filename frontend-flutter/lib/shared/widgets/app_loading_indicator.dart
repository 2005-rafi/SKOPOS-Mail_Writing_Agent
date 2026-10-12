import 'package:flutter/material.dart';
import '../../core/design_system/component_tokens.dart';
import '../../core/design_system/semantic_colors.dart';
import '../../core/design_system/spacing_tokens.dart';

/// Loading indicator in inline and full page overlay modes.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = ComponentTokens.iconSizeLg,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: semantic.actionPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: SpacingTokens.md),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: semantic.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
