import 'package:flutter/material.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../generated/l10n.dart';
import '../models/operation_step.dart';

class StepProgress extends StatelessWidget {
  final List<OperationStep> steps;
  final int currentIndex;

  const StepProgress({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  String _getStepName(OperationStep step, S l10n) {
    switch (step.type) {
      case StepType.selectFile:
        return l10n.stepSelectBoot;
      case StepType.backupBoot:
        return l10n.stepBackupBoot;
      case StepType.patchImage:
        return l10n.stepPatchImage;
      case StepType.saveFile:
        return l10n.stepSaveFile;
      case StepType.rebootToFastboot:
        return l10n.stepRebootToFastboot;
      case StepType.flashImage:
        return l10n.stepFlashDevice;
      case StepType.rebootDevice:
        return l10n.stepRebootComplete;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progress = steps.isEmpty ? 0.0 : (currentIndex + 1) / steps.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                l10n.operationProgress,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...steps.map((step) => _buildStepItem(context, step, l10n)),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, OperationStep step, S l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (step.status) {
      case StepStatus.pending:
        icon = Icons.radio_button_unchecked;
        iconColor = colorScheme.outline;
        bgColor = Colors.transparent;
        break;
      case StepStatus.inProgress:
        icon = Icons.pending;
        iconColor = colorScheme.primary;
        bgColor = colorScheme.primary.withValues(alpha: 0.1);
        break;
      case StepStatus.completed:
        icon = Icons.check_circle;
        iconColor = semantic.success;
        bgColor = semantic.success.withValues(alpha: 0.1);
        break;
      case StepStatus.failed:
        icon = Icons.error;
        iconColor = colorScheme.error;
        bgColor = colorScheme.error.withValues(alpha: 0.1);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey(step.status),
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStepName(step, l10n),
                  style: TextStyle(
                    fontSize: 13,
                    color: step.status == StepStatus.pending
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontWeight: step.status == StepStatus.inProgress
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (step.errorMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.errorMessage!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (step.status == StepStatus.inProgress)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
