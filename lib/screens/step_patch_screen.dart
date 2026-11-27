import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../generated/l10n.dart';

class StepPatchScreen extends StatefulWidget {
  const StepPatchScreen({super.key});

  @override
  State<StepPatchScreen> createState() => _StepPatchScreenState();
}

class _StepPatchScreenState extends State<StepPatchScreen> {
  int _currentStep = 0;

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

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Consumer2<PatchProvider, DeviceProvider>(
      builder: (context, patchProvider, deviceProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.stepOperation),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetSteps,
                tooltip: l10n.reset,
              ),
              if (patchProvider.logs.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.save_alt),
                  onPressed: () async {
                    final path = await patchProvider.exportLogs();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.logsSaved(path))),
                      );
                    }
                  },
                  tooltip: l10n.exportLogsTooltip,
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
                      child: _buildCurrentStep(patchProvider, deviceProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildCurrentStep(
      PatchProvider patchProvider, DeviceProvider deviceProvider) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(patchProvider);
      case 1:
        return _buildStep2(patchProvider);
      case 2:
        return _buildStep3(deviceProvider);
      case 3:
        return _buildStep4(patchProvider, deviceProvider);
      default:
        return _buildStep1(patchProvider);
    }
  }

  Widget _buildStep1(PatchProvider patchProvider) {
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
        FilledButton.icon(
          onPressed:
              patchProvider.isRunning || patchProvider.selectedFilePath == null
                  ? null
                  : () async {
                      final versionProvider = context.read<VersionProvider>();
                      final success =
                          await patchProvider.patchOnly(versionProvider);
                      if (success && mounted) {
                        _nextStep();
                      }
                    },
          icon: patchProvider.isRunning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.build),
          label: Text(patchProvider.isRunning ? l10n.patching : l10n.startPatch),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        const SizedBox(height: 20),
        LogConsole(
          logs: patchProvider.logs,
          maxHeight: 220,
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
          onClear: patchProvider.isRunning ? null : patchProvider.clearLogs,
        ),
      ],
    );
  }

  Widget _buildStep2(PatchProvider patchProvider) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

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
                    const Icon(Icons.check_circle, color: Colors.green),
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
                  patchProvider.patchedFilePath ?? l10n.unknown,
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

  Widget _buildStep3(DeviceProvider deviceProvider) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(l10n.step3, l10n.step3Desc),
        const SizedBox(height: 20),
        const DeviceStatusCard(showRefreshButton: true),
        const SizedBox(height: 24),
        if (deviceProvider.hasAdbDevice) ...[
          FilledButton.icon(
            onPressed: deviceProvider.isChecking
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
        if (!deviceProvider.hasAdbDevice) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
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
            onPressed:
                deviceProvider.hasFastbootDevice ? _nextStep : null,
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
  }

  Widget _buildStep4(
      PatchProvider patchProvider, DeviceProvider deviceProvider) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

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
                  patchProvider.patchedFilePath ?? l10n.unknown,
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
        if (deviceProvider.hasFastbootDevice) ...[
          FilledButton.icon(
            onPressed: patchProvider.isRunning
                ? null
                : () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    final success = await deviceProvider.flashBoot(
                      patchProvider.patchedFilePath!,
                      onLog: (line) {},
                    );

                    if (success && mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.flashSuccess),
                          backgroundColor: Colors.green,
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
            icon: const Icon(Icons.flash_on),
            label: Text(l10n.flashBoot),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
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
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _prevStep,
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