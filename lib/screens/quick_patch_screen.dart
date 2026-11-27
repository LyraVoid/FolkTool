import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../generated/l10n.dart';

class QuickPatchScreen extends StatefulWidget {
  const QuickPatchScreen({super.key});

  @override
  State<QuickPatchScreen> createState() => _QuickPatchScreenState();
}

class _QuickPatchScreenState extends State<QuickPatchScreen> {
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VersionProvider>().loadVersions();
    });
  }

  void _startPatch() async {
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

  void _cancelOperation() {
    context.read<PatchProvider>().cancelOperation();
  }

  void _exportLogs(BuildContext context) async {
    final l10n = S.of(context);
    final patchProvider = context.read<PatchProvider>();
    final path = await patchProvider.exportLogs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logsSaved(path))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Consumer<PatchProvider>(
      builder: (context, patchProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.oneClickFlash),
            actions: [
              if (patchProvider.logs.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.save_alt),
                  onPressed: () => _exportLogs(context),
                  tooltip: l10n.exportLogsTooltip,
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
                    if (patchProvider.steps.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 12),
                      if (patchProvider.phase != FlashingPhase.idle)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Phase: ${patchProvider.phase.name}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      StepProgress(
                        steps: patchProvider.steps,
                        currentIndex: patchProvider.currentStepIndex,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Divider(),
                    const SizedBox(height: 16),
                    LogConsole(
                      logs: patchProvider.logs,
                      maxHeight: 250,
                      onExport: () async {
                        final device = context.read<DeviceProvider>().currentDevice;
                        final redact =
                            context.read<SettingsProvider>().redactDiagnostics;
                        final path = await patchProvider.exportDiagnostics(
                          deviceInfo: device,
                          redact: redact,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Diagnostics saved: $path')),
                          );
                        }
                      },
                      onClear: patchProvider.isRunning
                          ? null
                          : patchProvider.clearLogs,
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(patchProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(PatchProvider patchProvider) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (patchProvider.isRunning) {
      return FilledButton.icon(
        onPressed: _cancelOperation,
        icon: const Icon(Icons.cancel),
        label: Text(l10n.cancelOperation),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
    }

    if (patchProvider.isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
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

    if (patchProvider.isFailed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (patchProvider.lastError != null)
            ErrorBanner(
              error: patchProvider.lastError!,
              onRetry: patchProvider.canSafelyRetry ? patchProvider.reset : null,
              onDismiss: patchProvider.clearError,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
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
                  if (patchProvider.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      patchProvider.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (patchProvider.lastError == null && patchProvider.canSafelyRetry) ...[
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
          if (patchProvider.backupFilePath != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final deviceProvider = context.read<DeviceProvider>();
                if (!deviceProvider.hasFastbootDevice) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connect device in Fastboot mode to restore stock boot.'),
                    ),
                  );
                  return;
                }
                final ok = await patchProvider.restoreStockBoot(deviceProvider);
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
      onPressed: _isStarting || patchProvider.selectedFilePath == null
          ? null
          : _startPatch,
      icon: _isStarting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.flash_on),
      label: Text(_isStarting ? l10n.flashing : l10n.startFlash),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    );
  }
}