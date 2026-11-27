import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/logging/log_entry.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/log_console.dart';
import '../../../generated/l10n.dart';
import '../../device/providers/device_provider.dart';
import '../../files/services/file_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/patch_provider.dart';
import '../providers/version_provider.dart';
import '../widgets/patch_inputs.dart';
import '../widgets/patch_target_selector.dart';
import '../widgets/version_selector.dart';

class SimplePatchScreen extends StatefulWidget {
  const SimplePatchScreen({super.key});

  @override
  State<SimplePatchScreen> createState() => _SimplePatchScreenState();
}

class _SimplePatchScreenState extends State<SimplePatchScreen> {
  final FileService _fileService = FileService();
  bool _isSaving = false;

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
    final versionProvider = context.read<VersionProvider>();

    if (patchProvider.selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectFile)),
      );
      return;
    }

    await patchProvider.patchOnly(versionProvider);
  }

  Future<void> _savePatchedFile() async {
    final l10n = S.of(context);
    final patchProvider = context.read<PatchProvider>();

    if (patchProvider.patchedFilePath == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final savedPath = await _fileService.savePatchedImageToLocation(
      patchProvider.patchedFilePath!,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (savedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fileSavedSuccessfully),
          backgroundColor: context.semantic.success,
        ),
      );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.simplePatch),
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
                _SimplePatchActionBar(
                  isSaving: _isSaving,
                  onStart: _startPatch,
                  onSave: _savePatchedFile,
                ),
                const SizedBox(height: 20),
                Selector<PatchProvider, ({List<LogEntry> logs, bool isRunning})>(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SimplePatchActionBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onSave;

  const _SimplePatchActionBar({
    required this.isSaving,
    required this.onStart,
    required this.onSave,
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
          String? patchedFile,
          AppError? lastError,
          String? errorMessage,
          bool canRetry,
        })>(
      selector: (_, p) => (
        opState: p.operationState,
        selectedFile: p.selectedFilePath,
        patchedFile: p.patchedFilePath,
        lastError: p.lastError,
        errorMessage: p.errorMessage,
        canRetry: p.canSafelyRetry,
      ),
      builder: (context, state, _) {
        final patchProvider = context.read<PatchProvider>();

        if (state.opState == PatchOperationState.running) {
          return FilledButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text(l10n.patching),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
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
                            l10n.patchOnlyComplete,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (state.patchedFile != null)
                            Text(
                              state.patchedFile!,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: patchProvider.reset,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.restart),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : onSave,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(l10n.savePatchedFile),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
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
            ],
          );
        }

        return FilledButton.icon(
          onPressed: state.selectedFile == null ? null : onStart,
          icon: const Icon(Icons.build),
          label: Text(l10n.startPatch),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        );
      },
    );
  }
}
