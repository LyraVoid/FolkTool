import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../generated/l10n.dart';

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
          content: Text(l10n.savedTo(savedPath)),
          backgroundColor: Colors.green,
        ),
      );
    }
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
            title: Text(l10n.simplePatch),
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
                    _buildActionButtons(patchProvider),
                    const SizedBox(height: 20),
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
                        l10n.patchOnlyComplete,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (patchProvider.patchedFilePath != null)
                        Text(
                          patchProvider.patchedFilePath!,
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
                  onPressed: _isSaving ? null : _savePatchedFile,
                  icon: _isSaving
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
        ],
      );
    }

    return FilledButton.icon(
      onPressed: patchProvider.selectedFilePath == null ? null : _startPatch,
      icon: const Icon(Icons.build),
      label: Text(l10n.startPatch),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    );
  }
}