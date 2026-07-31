import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n.dart';
import '../providers/version_provider.dart';
import '../models/patch_target.dart';

class PatchTargetSelector extends StatelessWidget {
  const PatchTargetSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  S.current.patchTarget,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<VersionProvider>(
              builder: (context, versionProvider, child) {
                return Row(
                  children: PatchTarget.values.map((target) {
                    final isSelected = versionProvider.currentTarget == target;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => versionProvider.setTarget(target),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.indigo[50] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.indigo[400]! : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  size: 18,
                                  color: isSelected ? Colors.indigo[600] : Colors.grey[500],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  target.displayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.indigo[800] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
