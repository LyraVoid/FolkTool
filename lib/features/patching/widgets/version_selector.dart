import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../models/kp_version.dart';
import '../providers/version_provider.dart';

class VersionSelector extends StatelessWidget {
  const VersionSelector({super.key});

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  Icons.settings_system_daydream,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.kernelPatchVersion,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n.selectVersionDesc,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<VersionProvider>(
              builder: (context, versionProvider, child) {
                if (versionProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (versionProvider.availableVersions.isEmpty) {
                  return _buildNoVersions(context);
                }

                return _buildVersionDropdown(context, versionProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionDropdown(
    BuildContext context,
    VersionProvider versionProvider,
  ) {
    final l10n = S.of(context);
    final selected = versionProvider.selectedVersion;

    final items = <DropdownMenuItem<KpVersion>>[
      for (final version in versionProvider.availableVersions)
        DropdownMenuItem<KpVersion>(
          value: version,
          child: _buildVersionItem(context, version),
        ),
      if (selected?.isCustom == true)
        DropdownMenuItem<KpVersion>(
          value: selected,
          child: _buildVersionItem(context, selected!),
        )
      else
        DropdownMenuItem<KpVersion>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.add_circle_outline,
                  color: Colors.orange[600], size: 18),
              const SizedBox(width: 8),
              Text(l10n.customVersion, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
    ];

    return DropdownButtonFormField<KpVersion>(
      key: ValueKey(selected),
      initialValue: selected,
      items: items,
      onChanged: (KpVersion? version) async {
        if (version == null) {
          await _selectCustomVersion(context, versionProvider);
        } else {
          versionProvider.selectVersion(version);
        }
      },
    );
  }

  Widget _buildVersionItem(BuildContext context, KpVersion version) {
    final l10n = S.of(context);
    if (version.isCustom) {
      return Text(
        l10n.versionCustom,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      );
    }
    return Text(
      '${version.source.displayName} ${version.version}',
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildNoVersions(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.noVersionsAvailable,
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: () => _selectCustomVersion(
              context,
              context.read<VersionProvider>(),
            ),
            child: Text(l10n.customVersion),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomVersion(
    BuildContext context,
    VersionProvider versionProvider,
  ) async {
    final l10n = S.of(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: l10n.selectCustomVersion,
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final success = await versionProvider.selectCustomVersion(filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.customVersionSaved : l10n.invalidVersionFile,
            ),
          ),
        );
      }
    }
  }
}