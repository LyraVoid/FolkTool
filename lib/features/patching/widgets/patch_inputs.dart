import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../generated/l10n.dart';
import '../../files/services/file_service.dart';
import '../providers/patch_provider.dart';

/// Shared boot image picker card synchronized with [PatchProvider] via fine-grained [Selector].
class BootImageSelectorCard extends StatelessWidget {
  const BootImageSelectorCard({
    super.key,
    this.onSelectBootImage,
  });

  final Future<void> Function()? onSelectBootImage;

  Future<void> _handleSelect(BuildContext context) async {
    if (onSelectBootImage != null) {
      await onSelectBootImage!();
      return;
    }
    final path = await FileService().selectBootImage();
    if (path != null && context.mounted) {
      context.read<PatchProvider>().setSelectedFile(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    return Selector<PatchProvider, ({String? selectedPath, bool isRunning})>(
      selector: (_, p) => (
        selectedPath: p.selectedFilePath,
        isRunning: p.isRunning,
      ),
      builder: (context, state, _) {
        final selectedPath = state.selectedPath;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
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
                  onTap:
                      state.isRunning ? null : () => _handleSelect(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
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
                            selectedPath ?? l10n.clickToSelectFile,
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedPath != null
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedPath != null)
                          Icon(
                            Icons.check_circle,
                            color: semantic.success,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shared KPM module multi-selector card synchronized with [PatchProvider].
class KpmModulesSelectorCard extends StatelessWidget {
  const KpmModulesSelectorCard({
    super.key,
    this.onSelectModules,
  });

  final Future<void> Function()? onSelectModules;

  Future<void> _handleSelect(BuildContext context) async {
    if (onSelectModules != null) {
      await onSelectModules!();
      return;
    }
    final modules = await FileService().selectKpmModules();
    if (modules.isNotEmpty && context.mounted) {
      final patchProvider = context.read<PatchProvider>();
      final updated = Set<String>.from(patchProvider.selectedKpmModules)
        ..addAll(modules);
      patchProvider.setKpmModules(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Selector<PatchProvider, ({List<String> modules, bool isRunning})>(
      selector: (_, p) => (
        modules: p.selectedKpmModules.toList(growable: false),
        isRunning: p.isRunning,
      ),
      builder: (context, state, _) {
        final patchProvider = context.read<PatchProvider>();
        final modules = state.modules;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                        onPressed: state.isRunning
                            ? null
                            : patchProvider.clearKpmModules,
                        child: Text(l10n.clearAllModules),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (modules.isEmpty)
                  InkWell(
                    onTap: state.isRunning
                        ? null
                        : () => _handleSelect(context),
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
                            Icon(
                              Icons.add_circle_outline,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
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
                                      Icon(
                                        Icons.insert_drive_file_outlined,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
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
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: state.isRunning
                                    ? null
                                    : () => patchProvider.removeKpmModule(path),
                                tooltip: l10n.removeModule,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton.icon(
                          onPressed: state.isRunning
                              ? null
                              : () => _handleSelect(context),
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
      },
    );
  }
}
