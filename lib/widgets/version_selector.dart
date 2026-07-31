import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/version_provider.dart';
import '../models/kp_version.dart';
import '../generated/l10n.dart';

class VersionSelector extends StatelessWidget {
  const VersionSelector({super.key});

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.settings_system_daydream, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.kernelPatchVersion,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        l10n.selectVersionDesc,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
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
  
  Widget _buildVersionDropdown(BuildContext context, VersionProvider versionProvider) {
    final l10n = S.of(context);
    final selected = versionProvider.selectedVersion;

    // 构建菜单项列表
    final items = <DropdownMenuItem<KpVersion>>[];

    // 添加预设版本
    for (final version in versionProvider.availableVersions) {
      items.add(DropdownMenuItem<KpVersion>(
        value: version,
        child: _buildVersionItem(context, version),
      ));
    }

    // 如果当前选择的是自定义版本，添加到列表中
    if (selected?.isCustom == true) {
      items.add(DropdownMenuItem<KpVersion>(
        value: selected,
        child: _buildVersionItem(context, selected!),
      ));
    }

    // 只有当没有选择自定义版本时，才添加"添加自定义"选项
    if (selected?.isCustom != true) {
      items.add(DropdownMenuItem<KpVersion>(
        value: null,
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.orange[600], size: 18),
            const SizedBox(width: 8),
            Text(l10n.customVersion, style: TextStyle(fontSize: 13)),
          ],
        ),
      ));
    }

    return DropdownButtonFormField<KpVersion>(
      value: selected,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
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
      return Text(l10n.versionCustom, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500));
    }
    return Text(
      '${version.source.displayName} ${version.version}',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
  
  Widget _buildNoVersions(BuildContext context) {
    final l10n = S.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.noVersionsAvailable,
              style: TextStyle(fontSize: 12, color: Colors.red[700]),
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
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.customVersionSaved)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.invalidVersionFile)),
          );
        }
      }
    }
  }
}
