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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectFile() async {
    final path = await _fileService.selectBootImage();
    if (path != null) {
      final patchProvider = context.read<PatchProvider>();
      patchProvider.setSelectedFile(path);
    }
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

    setState(() {
      _isSaving = false;
    });

    if (savedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fileSavedSuccessfully),
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
            centerTitle: true,
            elevation: 0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PatchTargetSelector(),
                const SizedBox(height: 16),
                const VersionSelector(),
                const SizedBox(height: 16),
                _buildFileSelector(patchProvider),
                const SizedBox(height: 16),
                _buildKpmModuleSelector(patchProvider),
                const SizedBox(height: 24),
                _buildActionButtons(patchProvider),
                const SizedBox(height: 24),
                LogConsole(
                  logs: patchProvider.logs,
                  maxHeight: 250,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileSelector(PatchProvider patchProvider) {
    final l10n = S.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_drive_file, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  l10n.selectBootImage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: patchProvider.isRunning ? null : _selectFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        patchProvider.selectedFilePath ?? l10n.clickToSelectFile,
                        style: TextStyle(
                          fontSize: 13,
                          color: patchProvider.selectedFilePath != null
                              ? Colors.grey[800]
                              : Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (patchProvider.selectedFilePath != null)
                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
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

    if (patchProvider.isRunning) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
        label: Text(l10n.patching),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.patchOnlyComplete,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[800],
                        ),
                      ),
                      if (patchProvider.patchedFilePath != null)
                        Text(
                          patchProvider.patchedFilePath!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
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
                  onPressed: () {
                    patchProvider.reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.restart),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _savePatchedFile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(l10n.savePatchedFile),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 12),
                    Text(
                      l10n.operationFailed,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[800],
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
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              patchProvider.reset();
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: patchProvider.selectedFilePath == null ? null : _startPatch,
      icon: const Icon(Icons.build),
      label: Text(l10n.startPatch),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _selectKpmModules() async {
    final modules = await _fileService.selectKpmModules();
    if (modules.isNotEmpty) {
      final patchProvider = context.read<PatchProvider>();
      final currentModules = Set<String>.from(patchProvider.selectedKpmModules);
      currentModules.addAll(modules);
      patchProvider.setKpmModules(currentModules);
    }
  }

  Widget _buildKpmModuleSelector(PatchProvider patchProvider) {
    final l10n = S.of(context);
    final modules = patchProvider.selectedKpmModules.toList();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  l10n.kpmModules,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                if (modules.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${modules.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (modules.isNotEmpty)
                  TextButton(
                    onPressed: patchProvider.isRunning
                        ? null
                        : () => patchProvider.clearKpmModules(),
                    child: Text(
                      l10n.clearAllModules,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (modules.isEmpty)
              InkWell(
                onTap: patchProvider.isRunning ? null : _selectKpmModules,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.grey[400], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.selectKpmModules,
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.insert_drive_file, size: 16, color: Colors.purple[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                            onPressed: patchProvider.isRunning
                                ? null
                                : () => patchProvider.removeKpmModule(path),
                            tooltip: l10n.removeModule,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton.icon(
                      onPressed: patchProvider.isRunning ? null : _selectKpmModules,
                      icon: Icon(Icons.add, size: 16),
                      label: Text(l10n.selectKpmModules),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple[600],
                      ),
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
