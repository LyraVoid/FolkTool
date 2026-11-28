import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_semantic_colors.dart';
import '../errors/app_error.dart';

/// Structured error banner displaying actionable recovery guidance and
/// hiding Retry when the device may be in an uncertain state.
class ErrorBanner extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onViewLogs;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onViewLogs,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantic = context.semantic;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                error.deviceSafe
                    ? Icons.error_outline_rounded
                    : Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  error.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Badge(
                label: error.categoryName,
                backgroundColor: colorScheme.error.withValues(alpha: 0.14),
                foregroundColor: colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              _Badge(
                label: error.deviceSafe
                    ? 'Device Safe'
                    : 'Check Device State',
                backgroundColor: (error.deviceSafe
                        ? semantic.success
                        : colorScheme.error)
                    .withValues(alpha: 0.14),
                foregroundColor:
                    error.deviceSafe ? semantic.success : colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
          if (error.reason != null && error.reason!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Why: ${error.reason}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer.withValues(alpha: 0.85),
              ),
            ),
          ],
          if (error.affectedStage != null &&
              error.affectedStage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Stage: ${error.affectedStage}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onErrorContainer.withValues(alpha: 0.75),
              ),
            ),
          ],
          if (error.nextSteps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      error.nextSteps,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: error.toClipboardText()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error details copied to clipboard'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 15),
                label: const Text('Copy Details'),
              ),
              if (onViewLogs != null)
                OutlinedButton.icon(
                  onPressed: onViewLogs,
                  icon: const Icon(Icons.article_outlined, size: 15),
                  label: const Text('View Logs'),
                ),
              if (error.canSafelyRetry && onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 15),
                  label: const Text('Retry'),
                ),
              if (onDismiss != null)
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }
}
