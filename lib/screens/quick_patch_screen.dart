import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../generated/l10n.dart';

class QuickPatchScreen extends StatefulWidget {
  const QuickPatchScreen({super.key});

  @override
  State<QuickPatchScreen> createState() => _QuickPatchScreenState();
}

class _QuickPatchScreenState extends State<QuickPatchScreen> {
  final FileService _fileService = FileService();
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

  Future<void> _selectFile() async {
    final path = await _fileService.selectBootImage();
    if (path != null && mounted) {
      context.read<PatchProvider>().setSelectedFile(path);
    }
  }

  void _startPatch() async {
    final l10n = S.of(context);
    final patchProvider = context.read<PatchProvider>();
    final deviceProvider = context.read<DeviceProvider>();
    final versionProvider = context.read<VersionProvider>();

    if (patchProvider.selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectFile)),
      );
      return;
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
                    _buildFileSelector(patchProvider),
                    const SizedBox(height: 16),
                    _buildKpmModuleSelector(patchProvider),
                    const SizedBox(height: 20),
                    if (patchProvider.steps.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 16),
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

  Widget _buildFileSelector(PatchProvider patchProvider) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_drive_file_outlined,
                    color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.selectBootImage,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: patchProvider.isRunning ? null : _selectFile,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        patchProvider.selectedFilePath ??
                            l10n.clickToSelectFile,
                        style: TextStyle(
                          fontSize: 13,
                          color: patchProvider.selectedFilePath != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (patchProvider.selectedFilePath != null)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                  child: Text(
                    l10n.quickPatchComplete,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: patchProvider.reset,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.restart),
            style: FilledButton.styleFrom(
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

  Future<void> _selectKpmModules() async {
    final modules = await _fileService.selectKpmModules();
    if (modules.isNotEmpty && mounted) {
      final patchProvider = context.read<PatchProvider>();
      final currentModules = Set<String>.from(patchProvider.selectedKpmModules);
      currentModules.addAll(modules);
      patchProvider.setKpmModules(currentModules);
    }
  }

  Widget _buildKpmModuleSelector(PatchProvider patchProvider) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final modules = patchProvider.selectedKpmModules.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.kpmModules,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (modules.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${modules.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (modules.isNotEmpty)
                  TextButton(
                    onPressed: patchProvider.isRunning
                        ? null
                        : patchProvider.clearKpmModules,
                    child: Text(l10n.clearAllModules),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (modules.isEmpty)
              InkWell(
                onTap: patchProvider.isRunning ? null : _selectKpmModules,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: colorScheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.selectKpmModules,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...modules.map((path) {
                    final fileName = path.split('\\').last.split('/').last;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.insert_drive_file_outlined,
                                      size: 16, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 18, color: colorScheme.onSurfaceVariant),
                            onPressed: patchProvider.isRunning
                                ? null
                                : () => patchProvider.removeKpmModule(path),
                            tooltip: l10n.removeModule,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton.icon(
                      onPressed:
                          patchProvider.isRunning ? null : _selectKpmModules,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.selectKpmModules),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
