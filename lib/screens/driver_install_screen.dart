import 'package:flutter/material.dart';
import '../services/services.dart';
import '../generated/l10n.dart';

class DriverInstallScreen extends StatefulWidget {
  const DriverInstallScreen({super.key});

  @override
  State<DriverInstallScreen> createState() => _DriverInstallScreenState();
}

class _DriverInstallScreenState extends State<DriverInstallScreen> {
  final DriverService _driverService = DriverService();
  String? _installingDriver;
  String? _installedDriver;

  Future<void> _installDriver(DriverInfo driver) async {
    final l10n = S.of(context);

    setState(() {
      _installingDriver = driver.executableName;
    });

    final success = await _driverService.installDriver(driver.executableName);

    if (!mounted) return;
    setState(() {
      _installingDriver = null;
      if (success) {
        _installedDriver = driver.executableName;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.installDriverSuccess : l10n.installDriverFailed(''),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverInstallPage),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDriverCard(
                  driver: DriverService.drivers[0],
                  title: l10n.qualcommDriver64,
                  description: l10n.qualcommDriver64Desc,
                  color: Colors.blue,
                ),
                const SizedBox(height: 14),
                _buildDriverCard(
                  driver: DriverService.drivers[1],
                  title: l10n.qualcommDriver32,
                  description: l10n.qualcommDriver32Desc,
                  color: Colors.green,
                ),
                const SizedBox(height: 14),
                _buildDriverCard(
                  driver: DriverService.drivers[2],
                  title: l10n.mediatekDriver,
                  description: l10n.mediatekDriverDesc,
                  color: Colors.purple,
                ),
                const SizedBox(height: 14),
                _buildDriverCard(
                  driver: DriverService.drivers[3],
                  title: l10n.oneplusAdbDriver,
                  description: l10n.oneplusAdbDriverDesc,
                  color: Colors.red,
                ),
                const SizedBox(height: 14),
                _buildDriverCard(
                  driver: DriverService.drivers[4],
                  title: l10n.oppoAdbDriver,
                  description: l10n.oppoAdbDriverDesc,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard({
    required DriverInfo driver,
    required String title,
    required String description,
    required Color color,
  }) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isInstalling = _installingDriver == driver.executableName;
    final isInstalled = _installedDriver == driver.executableName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.usb,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
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
              ],
            ),
            const SizedBox(height: 16),
            if (isInstalled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.installDriverSuccess,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: isInstalling ? null : () => _installDriver(driver),
                  icon: isInstalling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: Text(
                    isInstalling ? l10n.installing : l10n.installDriver,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
