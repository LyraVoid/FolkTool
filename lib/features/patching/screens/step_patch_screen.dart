import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/logging/log_entry.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/log_console.dart';
import '../../../generated/l10n.dart';
import '../../device/providers/device_provider.dart';
import '../../device/widgets/device_status_card.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/patch_provider.dart';
import '../providers/version_provider.dart';
import '../widgets/patch_inputs.dart';
import '../widgets/patch_target_selector.dart';
import '../widgets/version_selector.dart';

class StepPatchScreen extends StatefulWidget {
  const StepPatchScreen({super.key});

  @override
  State<StepPatchScreen> createState() => _StepPatchScreenState();
}

class _StepPatchScreenState extends State<StepPatchScreen> {
  final GlobalKey _logConsoleKey = GlobalKey();
  int _currentStep = 0;

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

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _resetSteps() {
    setState(() {
      _currentStep = 0;
    });
    context.read<PatchProvider>().reset();
  }

  Future<void> _exportLogs(BuildContext context) async {
    final l10n = S.of(context);
    final path = await context.read<PatchProvider>().exportLogs();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stepOperation),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetSteps,
            tooltip: l10n.reset,
          ),
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
      body: Column(
        children: [
          _buildStepIndicator(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: _buildCurrentStep(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Row(
            children: List.generate(4, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 3) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(context);
      case 1:
        return _buildStep2(context);
      case 2:
        return _buildStep3(context);
      case 3:
        return _buildStep4(context);
      default:
        return _buildStep1(context);
    }
  }

  Widget _buildStep1(BuildContext context) {
    final l10n = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle(l10n.step1, l10n.step1Desc),
        const SizedBox(height: 20),
        const PatchTargetSelector(),
        const SizedBox(height: 16),
        const VersionSelector(),
        const SizedBox(height: 16),
        const BootImageSelectorCard(),
        const SizedBox(height: 16),
        const KpmModulesSelectorCard(),
        const SizedBox(height: 20),
        Selector<PatchProvider, ({bool isRunning, bool hasFile})>(
          selector: (_, p) => (
            isRunning: p.isRunning,
            hasFile: p.selectedFilePath != null,
          ),
          builder: (context, state, _) {
            final patchProvider = context.read<PatchProvider>();
            return FilledButton.icon(
              onPressed: state.isRunning || !state.hasFile
                  ? null
                  : () async {
                      final versionProvider = context.read<VersionProvider>();
                      final success =
                          await patchProvider.patchOnly(versionProvider);
                      if (success && mounted) {
                        _nextStep();
                      }
                    },
              icon: state.isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.build),
              label: Text(state.isRunning ? l10n.patching : l10n.startPatch),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
            );
          },
        ),
        Selector<PatchProvider, ({AppError? lastError, bool canRetry})>(
          selector: (_, p) => (
            lastError: p.lastError,
            canRetry: p.canSafelyRetry,
          ),
          builder: (context, errState, _) {
            if (errState.lastError == null) return const SizedBox.shrink();
            final patchProvider = context.read<PatchProvider>();
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ErrorBanner(
                error: errState.lastError!,
                onRetry: errState.canRetry ? patchProvider.clearError : null,
                onViewLogs: _scrollToLogs,
                onDismiss: patchProvider.clearError,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
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
              maxHeight: 220,
              onExport: () => _exportDiagnostics(context),
              onClear: logState.isRunning ? null : patchProvider.clearLogs,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final patchedFilePath = context.select<PatchProvider, String?>(
      (p) => p.patchedFilePath,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(l10n.step2, l10n.step2Desc),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: semantic.success),
                    const SizedBox(width: 8),
                    Text(
                      l10n.patchedFile,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  patchedFilePath ?? l10n.unknown,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'Consolas',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            OutlinedButton(
              onPressed: _prevStep,
              child: Text(l10n.previousStep),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: _nextStep,
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.nextStep),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    return Selector<DeviceProvider,
        ({bool hasAdb, bool hasFastboot, bool isChecking})>(
      selector: (_, p) => (
        hasAdb: p.hasAdbDevice,
        hasFastboot: p.hasFastbootDevice,
        isChecking: p.isChecking,
      ),
      builder: (context, devState, _) {
        final deviceProvider = context.read<DeviceProvider>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle(l10n.step3, l10n.step3Desc),
            const SizedBox(height: 20),
            const DeviceStatusCard(showRefreshButton: true),
            const SizedBox(height: 24),
            if (devState.hasAdb) ...[
              FilledButton.icon(
                onPressed: devState.isChecking
                    ? null
                    : () async {
                        final success = await deviceProvider.rebootToFastboot();
                        if (success) {
                          await deviceProvider.waitForFastboot();
                          if (deviceProvider.hasFastbootDevice && mounted) {
                            _nextStep();
                          }
                        }
                      },
                icon: const Icon(Icons.restart_alt),
                label: Text(l10n.rebootToFastboot),
              ),
              const SizedBox(height: 16),
            ],
            if (!devState.hasAdb) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: semantic.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: semantic.warning.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: semantic.warning),
                        const SizedBox(width: 8),
                        Text(
                          l10n.manuallyEnterFastboot,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.manuallyEnterFastbootDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: devState.hasFastboot ? _nextStep : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.deviceInFastboot),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _prevStep,
              child: Text(l10n.previousStep),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep4(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    final patchedFilePath = context.select<PatchProvider, String?>(
      (p) => p.patchedFilePath,
    );
    final isRunning = context.select<PatchProvider, bool>((p) => p.isRunning);
    final hasFastboot =
        context.select<DeviceProvider, bool>((p) => p.hasFastbootDevice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(l10n.step4, l10n.step4Desc),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_android, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.flashFile,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  patchedFilePath ?? l10n.unknown,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'Consolas',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (hasFastboot) ...[
          FilledButton.icon(
            onPressed: isRunning || patchedFilePath == null
                ? null
                : () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final deviceProvider = context.read<DeviceProvider>();
                    final patchProvider = context.read<PatchProvider>();

                    final success =
                        await patchProvider.flashPatchedBootOnDevice(
                      deviceProvider,
                    );

                    if (success && context.mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.flashSuccess),
                          backgroundColor: semantic.success,
                        ),
                      );

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.flashComplete),
                          content: Text(l10n.flashCompleteDesc),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.rebootLater),
                            ),
                            FilledButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await deviceProvider.rebootDevice();
                              },
                              child: Text(l10n.rebootNow),
                            ),
                          ],
                        ),
                      );
                    }
                  },
            icon: isRunning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.flash_on),
            label: Text(isRunning ? l10n.flashing : l10n.flashBoot),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.noFastbootDevice,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        Selector<PatchProvider, ({AppError? lastError, bool canRetry})>(
          selector: (_, p) => (
            lastError: p.lastError,
            canRetry: p.canSafelyRetry,
          ),
          builder: (context, errState, _) {
            if (errState.lastError == null) return const SizedBox.shrink();
            final patchProvider = context.read<PatchProvider>();
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ErrorBanner(
                error: errState.lastError!,
                onRetry: errState.canRetry ? patchProvider.clearError : null,
                onViewLogs: _scrollToLogs,
                onDismiss: patchProvider.clearError,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Selector<PatchProvider, ({List<LogEntry> logs, bool isRunning})>(
          key: _logConsoleKey,
          selector: (_, p) => (
            logs: List<LogEntry>.unmodifiable(p.logs),
            isRunning: p.isRunning,
          ),
          builder: (context, logState, _) {
            if (logState.logs.isEmpty) return const SizedBox.shrink();
            final patchProvider = context.read<PatchProvider>();
            return LogConsole(
              logs: logState.logs,
              maxHeight: 200,
              onExport: () => _exportDiagnostics(context),
              onClear: logState.isRunning ? null : patchProvider.clearLogs,
            );
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: isRunning ? null : _prevStep,
          child: Text(l10n.previousStep),
        ),
      ],
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
