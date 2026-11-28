import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../../generated/l10n.dart';
import '../providers/device_provider.dart';

class DeviceStatusCard extends StatelessWidget {
  final bool showRefreshButton;
  final VoidCallback? onRefresh;

  const DeviceStatusCard({
    super.key,
    this.showRefreshButton = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.devices,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.deviceStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusPill(context, deviceProvider, l10n),
                      const Spacer(),
                      if (showRefreshButton)
                        SizedBox(
                          height: 32,
                          child: deviceProvider.isManualChecking
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
                                  onPressed: deviceProvider.isChecking
                                      ? null
                                      : () {
                                          if (onRefresh != null) {
                                            onRefresh!();
                                          } else {
                                            deviceProvider
                                                .manualRefreshDevices();
                                          }
                                        },
                                  icon: const Icon(Icons.refresh, size: 18),
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
                  _buildStatusContent(context, deviceProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusPill(
    BuildContext context,
    DeviceProvider provider,
    S l10n,
  ) {
    final semantic = context.semantic;
    Color dotColor;
    String label;
    switch (provider.connectionState) {
      case DeviceConnectionState.adbConnected:
        dotColor = semantic.success;
        label = 'ADB';
        break;
      case DeviceConnectionState.fastbootConnected:
        dotColor = semantic.success;
        label = 'Fastboot';
        break;
      case DeviceConnectionState.adbUnauthorized:
        dotColor = semantic.warning;
        label = 'Unauthorized';
        break;
      case DeviceConnectionState.adbOffline:
        dotColor = semantic.warning;
        label = 'Offline';
        break;
      case DeviceConnectionState.multipleDevices:
        dotColor = semantic.warning;
        label = 'Multiple';
        break;
      case DeviceConnectionState.checking:
        dotColor = Theme.of(context).colorScheme.primary;
        label = l10n.checking;
        break;
      case DeviceConnectionState.disconnected:
        dotColor = Theme.of(context).colorScheme.outline;
        label = l10n.noDeviceDetected;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, DeviceProvider provider) {
    final l10n = S.of(context);

    if (!provider.driverInstalled) {
      return _buildWarningItem(
        context,
        l10n.checkingDriver,
        l10n.checkingDriverDesc,
        context.semantic.warning,
      );
    }

    switch (provider.connectionState) {
      case DeviceConnectionState.disconnected:
        return _buildDisconnected(context);
      case DeviceConnectionState.adbConnected:
        return _buildAdbConnected(context, provider);
      case DeviceConnectionState.adbUnauthorized:
        final dev = provider.unauthorizedAdbDevices.first;
        return _buildWarningItem(
          context,
          'USB Debugging Unauthorized (${dev.serial})',
          'Unlock your phone screen and tap "Allow USB debugging" (check "Always allow from this computer").',
          context.semantic.warning,
        );
      case DeviceConnectionState.adbOffline:
        final dev = provider.offlineAdbDevices.first;
        return _buildWarningItem(
          context,
          'ADB Device Offline (${dev.serial})',
          'Reconnect the USB cable, try a USB 2.0/rear port, or toggle USB Debugging off and back on.',
          context.semantic.warning,
        );
      case DeviceConnectionState.multipleDevices:
        return _buildMultipleDevices(context, provider);
      case DeviceConnectionState.fastbootConnected:
        return _buildFastbootConnected(context, provider);
      case DeviceConnectionState.checking:
        return _buildChecking(context);
    }
  }

  Widget _buildDisconnected(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildStatusItem(
          context,
          l10n.noDeviceDetected,
          l10n.noDeviceDetectedDesc,
          colorScheme.outline,
          Icons.usb_off,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.deviceConnectionTips,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.deviceConnectionTipsDesc,
                style: TextStyle(
                  fontSize: 11.5,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleDevices(BuildContext context, DeviceProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final candidates = [
      ...provider.fastbootDevices,
      ...provider.authorizedAdbDevices,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWarningItem(
          context,
          'Multiple Devices Detected',
          'Select one target device or disconnect extra devices before flashing.',
          semantic.warning,
        ),
        if (candidates.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: candidates.map((d) {
              final selected = provider.selectedSerial == d.serial;
              return ChoiceChip(
                label: Text('${d.model ?? d.serial} (${d.stateText})'),
                selected: selected,
                selectedColor: colorScheme.primaryContainer,
                onSelected: (_) => provider.selectDevice(d.serial),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAdbConnected(BuildContext context, DeviceProvider provider) {
    final l10n = S.of(context);
    final device =
        provider.selectedTargetDevice ?? provider.authorizedAdbDevices.first;
    final details = <String>[
      l10n.serial(device.serial),
      if (device.model != null && device.model!.isNotEmpty) device.model!,
      if (device.androidVersion != null && device.androidVersion!.isNotEmpty)
        'Android ${device.androidVersion}',
      if (device.batteryLevel != null) 'Battery ${device.batteryLevel}%',
    ].join(' • ');

    return _buildStatusItem(
      context,
      l10n.adbConnected,
      details,
      context.semantic.success,
      Icons.android,
    );
  }

  Widget _buildFastbootConnected(BuildContext context, DeviceProvider provider) {
    final l10n = S.of(context);
    final device =
        provider.selectedTargetDevice ?? provider.fastbootDevices.first;
    final lockText = device.bootloaderUnlocked == null
        ? ''
        : (device.bootloaderUnlocked!
            ? ' • Bootloader Unlocked'
            : ' • Bootloader Locked');
    return _buildStatusItem(
      context,
      l10n.fastbootConnected,
      '${l10n.serial(device.serial)}$lockText',
      context.semantic.success,
      Icons.phone_android,
    );
  }

  Widget _buildChecking(BuildContext context) {
    final l10n = S.of(context);
    return _buildStatusItem(
      context,
      l10n.checking,
      l10n.scanning,
      Theme.of(context).colorScheme.primary,
      Icons.search,
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
