import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/logging/log_entry.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/log_console.dart';
import '../../../generated/l10n.dart';
import '../../device/providers/device_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/operation_step.dart';
import '../providers/patch_provider.dart';
import '../providers/version_provider.dart';
import '../widgets/patch_inputs.dart';
import '../widgets/patch_target_selector.dart';
import '../widgets/step_progress.dart';
import '../widgets/version_selector.dart';

class QuickPatchScreen extends StatefulWidget {
  const QuickPatchScreen({super.key});

  @override
  State<QuickPatchScreen> createState() => _QuickPatchScreenState();
}

class _QuickPatchScreenState extends State<QuickPatchScreen> {
  final GlobalKey _logConsoleKey = GlobalKey();
  bool _isStarting = false;

  void _scrollToLogs() {
    final logContext = _logConsoleKey.currentContext;
    if (logContext != null) {
      Scrollable.ensureVisible(
        logContext,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VersionProvider>().loadVersions();
    });
  }

  Future<void> _startPatch() async {
    final l10n = S.of(context);
    final patchProvider = context.read<PatchProvider>();
    final deviceProvider = context.read<DeviceProvider>();
    final versionProvider = context.read<VersionProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (patchProvider.selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectFile)),
      );
      return;
    }

    if (settingsProvider.confirmBeforeFlash) {
      final target = deviceProvider.selectedTargetDevice;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm One-Click Flash'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Device: ${target != null ? '${target.model ?? target.serial} (${target.stateText})' : 'None detected'}',
              ),
              const SizedBox(height: 6),
              Text('Boot Image: ${patchProvider.selectedFilePath}'),
              const SizedBox(height: 6),
              Text(
                'KernelPatch Version: ${versionProvider.selectedVersion ?? 'Default'}',
              ),
              const SizedBox(height: 12),
              const Text(
                'This will patch the boot image, reboot to Fastboot, and flash the boot partition. Ensure your bootloader is unlocked and do not disconnect USB during flashing.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Start Flashing'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _isStarting = true;
    });

    await patchProvider.startQuickPatch(deviceProvider, versionProvider);

    if (mounted) {
      setState(() {
        _isStarting = false;
      });
    }
  }

  Future<void> _exportLogs(BuildContext context) async {
    final l10n = S.of(context);
    final patchProvider = context.read<PatchProvider>();
    final path = await patchProvider.exportLogs();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logsSaved(path))),
      );
    }
  }

  Future<void> _exportDiagnostics(BuildContext context) async {
    final patchProvider = context.read<PatchProvider>();
    final device = context.read<DeviceProvider>().currentDevice;
    final redact = context.read<SettingsProvider>().redactDiagnostics;
    final path = await patchProvider.exportDiagnostics(
      deviceInfo: device,
      redact: redact,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diagnostics saved: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    final isRunning = context.select<PatchProvider, bool>((p) => p.isRunning);

    return PopScope(
      canPop: !isRunning,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Flashing/patching operation is active. Wait or cancel before exiting.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.oneClickFlash),
        actions: [
          Selector<PatchProvider, bool>(
            selector: (_, p) => p.logs.isNotEmpty,
            builder: (context, hasLogs, _) {
              if (!hasLogs) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.save_alt),
                onPressed: () => _exportLogs(context),
                tooltip: l10n.exportLogsTooltip,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PatchTargetSelector(),
                const SizedBox(height: 16),
                const VersionSelector(),
                const SizedBox(height: 16),
                const BootImageSelectorCard(),
                const SizedBox(height: 16),
                const KpmModulesSelectorCard(),
                const SizedBox(height: 20),
                Selector<
                    PatchProvider,
                    ({
                      FlashingPhase phase,
                      List<OperationStep> steps,
                      int currentIndex,
                    })>(
                  selector: (_, p) => (
                    phase: p.phase,
                    steps: p.steps,
                    currentIndex: p.currentStepIndex,
                  ),
                  builder: (context, progress, _) {
                    if (progress.steps.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),
                        if (progress.phase != FlashingPhase.idle)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Phase: ${progress.phase.name}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        StepProgress(
                          steps: progress.steps,
                          currentIndex: progress.currentIndex,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                const Divider(),
                const SizedBox(height: 16),
                Selector<PatchProvider, ({List<LogEntry> logs, bool isRunning})>(
                  key: _logConsoleKey,
                  selector: (_, p) => (
                    logs: List<LogEntry>.unmodifiable(p.logs),
                    isRunning: p.isRunning,
                  ),
                  builder: (context, logState, _) {
                    final patchProvider = context.read<PatchProvider>();
                    return LogConsole(
                      logs: logState.logs,
                      maxHeight: 250,
                      onExport: () => _exportDiagnostics(context),
                      onClear:
                          logState.isRunning ? null : patchProvider.clearLogs,
                    );
                  },
                ),
                const SizedBox(height: 20),
                _QuickPatchActionBar(
                  isStarting: _isStarting,
                  onStart: _startPatch,
                  onViewLogs: _scrollToLogs,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _QuickPatchActionBar extends StatelessWidget {
  final bool isStarting;
  final VoidCallback onStart;
  final VoidCallback onViewLogs;

  const _QuickPatchActionBar({
    required this.isStarting,
    required this.onStart,
    required this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    return Selector<
        PatchProvider,
        ({
          PatchOperationState opState,
          String? selectedFile,
          String? backupFile,
          AppError? lastError,
          String? errorMessage,
          bool canRetry,
        })>(
      selector: (_, p) => (
        opState: p.operationState,
        selectedFile: p.selectedFilePath,
        backupFile: p.backupFilePath,
        lastError: p.lastError,
        errorMessage: p.errorMessage,
        canRetry: p.canSafelyRetry,
      ),
      builder: (context, state, _) {
        final patchProvider = context.read<PatchProvider>();

        if (state.opState == PatchOperationState.running) {
          return FilledButton.icon(
            onPressed: patchProvider.cancelOperation,
            icon: const Icon(Icons.cancel),
            label: Text(l10n.cancelOperation),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          );
        }

        if (state.opState == PatchOperationState.completed) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: semantic.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: semantic.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: semantic.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.flashComplete,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            l10n.quickPatchComplete,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  patchProvider.reset();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.home),
                label: Text(l10n.home),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        }

        if (state.opState == PatchOperationState.failed) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.lastError != null)
                ErrorBanner(
                  error: state.lastError!,
                  onRetry: state.canRetry ? patchProvider.reset : null,
                  onViewLogs: onViewLogs,
                  onDismiss: patchProvider.clearError,
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: colorScheme.error),
                          const SizedBox(width: 12),
                          Text(
                            l10n.operationFailed,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (state.lastError == null && state.canRetry) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: patchProvider.reset,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
              if (state.backupFile != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final deviceProvider = context.read<DeviceProvider>();
                    if (!deviceProvider.hasFastbootDevice) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Connect device in Fastboot mode to restore stock boot.',
                          ),
                        ),
                      );
                      return;
                    }
                    final ok =
                        await patchProvider.restoreStockBoot(deviceProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Stock boot image restored.'
                                : 'Failed to restore stock boot image.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Stock Boot'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          );
        }

        return FilledButton.icon(
          onPressed:
              isStarting || state.selectedFile == null ? null : onStart,
          icon: isStarting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.flash_on),
          label: Text(isStarting ? l10n.flashing : l10n.startFlash),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        );
      },
    );
  }
}
