import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../generated/l10n.dart';

class ClientCheckCard extends StatefulWidget {
  const ClientCheckCard({super.key});

  @override
  State<ClientCheckCard> createState() => _ClientCheckCardState();
}

class _ClientCheckCardState extends State<ClientCheckCard> {
  @override
  void initState() {
    super.initState();
    // ADB 连接后自动检测客户端
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = context.read<DeviceProvider>();
      if (deviceProvider.hasAdbDevice) {
        deviceProvider.checkInstalledClients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        // 只有在 ADB 连接时才显示
        if (!deviceProvider.hasAdbDevice) {
          return const SizedBox.shrink();
        }
        
        return Card(
          elevation: 2,
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
                    Icon(
                      Icons.apps,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.clientCheck,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 32,
                      child: deviceProvider.isManualCheckingClients
                          ? Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : TextButton.icon(
                              onPressed: () => deviceProvider.manualRefreshClients(),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(l10n.refresh),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildClientList(context, deviceProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientList(BuildContext context, DeviceProvider provider) {
    final l10n = S.of(context);
    final apatchStatus = provider.apatchStatus;
    final folkpatchStatus = provider.folkpatchStatus;
    
    return Column(
      children: [
        // APatch 状态
        _buildClientItem(
          context: context,
          name: 'APatch',
          description: l10n.apatchDesc,
          icon: Icons.security,
          installed: apatchStatus.installed,
          installing: apatchStatus.installing,
          color: Colors.blue,
          onInstall: apatchStatus.installed 
              ? null 
              : () => _installClient(provider, ClientType.apatch),
        ),
        const SizedBox(height: 12),
        // FolkPatch 状态
        _buildClientItem(
          context: context,
          name: 'FolkPatch',
          description: l10n.folkpatchDesc,
          icon: Icons.extension,
          installed: folkpatchStatus.installed,
          installing: folkpatchStatus.installing,
          color: Colors.green,
          onInstall: folkpatchStatus.installed 
              ? null 
              : () => _installClient(provider, ClientType.folkpatch),
        ),
      ],
    );
  }

  Widget _buildClientItem({
    required BuildContext context,
    required String name,
    required String description,
    required IconData icon,
    required bool installed,
    required bool installing,
    required Color color,
    required VoidCallback? onInstall,
  }) {
    final l10n = S.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: installed 
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: installed 
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: installed 
                  ? Colors.green.withOpacity(0.2)
                  : color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              installed ? Icons.check_circle : icon,
              color: installed ? Colors.green : color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (installed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.installed,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!installed && onInstall != null)
            installing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : TextButton(
                    onPressed: onInstall,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      l10n.install,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  Future<void> _installClient(DeviceProvider provider, ClientType type) async {
    final l10n = S.of(context);
    final clientName = type == ClientType.apatch ? 'APatch' : 'FolkPatch';
    
    final success = await provider.installClient(
      type,
      onLog: (line) => debugPrint('[Install$clientName] $line'),
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.installSuccess(clientName)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.installFailed(clientName)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
