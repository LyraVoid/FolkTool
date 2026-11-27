import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../generated/l10n.dart';
import '../providers/device_provider.dart';

class ClientCheckCard extends StatefulWidget {
  const ClientCheckCard({super.key});

  @override
  State<ClientCheckCard> createState() => _ClientCheckCardState();
}

class _ClientCheckCardState extends State<ClientCheckCard> {
  @override
  void initState() {
    super.initState();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Selector<
        DeviceProvider,
        ({
          bool hasAdb,
          bool manualChecking,
          ClientInstallStatus apatch,
          ClientInstallStatus folkpatch,
        })>(
      selector: (_, p) => (
        hasAdb: p.hasAdbDevice,
        manualChecking: p.isManualCheckingClients,
        apatch: p.apatchStatus,
        folkpatch: p.folkpatchStatus,
      ),
      builder: (context, state, _) {
        final deviceProvider = context.read<DeviceProvider>();
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: !state.hasAdb
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Card(
                    key: const ValueKey('client-check-card'),
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
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.clientCheck,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 32,
                                child: state.manualChecking
                                    ? Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : TextButton.icon(
                                        onPressed: () => deviceProvider
                                            .manualRefreshClients(),
                                        icon: const Icon(Icons.refresh,
                                            size: 18),
                                        label: Text(l10n.refresh),
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildClientList(
                            context,
                            deviceProvider,
                            state.apatch,
                            state.folkpatch,
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

  Widget _buildClientList(
    BuildContext context,
    DeviceProvider provider,
    ClientInstallStatus apatchStatus,
    ClientInstallStatus folkpatchStatus,
  ) {
    final l10n = S.of(context);

    return Column(
      children: [
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
        _buildClientItem(
          context: context,
          name: 'FolkPatch',
          description: l10n.folkpatchDesc,
          icon: Icons.extension,
          installed: folkpatchStatus.installed,
          installing: folkpatchStatus.installing,
          color: context.semantic.success,
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
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final tint = installed ? semantic.success : colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (installed ? semantic.success : color).withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              installed ? Icons.check_circle : icon,
              color: installed ? semantic.success : color,
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (installed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: semantic.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.installed,
                          style: TextStyle(
                            fontSize: 10,
                            color: semantic.onSuccess,
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
                    color: colorScheme.onSurfaceVariant,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      l10n.install,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.installSuccess(clientName)
                : l10n.installFailed(clientName),
          ),
          backgroundColor:
              success ? context.semantic.success : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
