import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_semantic_colors.dart';
import '../../device/providers/device_provider.dart';
import '../../files/services/file_service.dart';
import '../../patching/providers/patch_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

/// Application settings screen for appearance, safety preferences, and maintenance.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final settings = context.watch<SettingsProvider>();
    final deviceProvider = context.read<DeviceProvider>();
    final patchProvider = context.read<PatchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            children: [
              const _SectionHeader(
                icon: Icons.palette_outlined,
                title: 'Appearance & Language',
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_outlined),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {themeProvider.themeMode},
                        onSelectionChanged: (selection) {
                          themeProvider.setThemeMode(selection.first);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Language', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('English')),
                          ButtonSegment(value: 'zh', label: Text('中文')),
                        ],
                        selected: {localeProvider.locale.languageCode},
                        onSelectionChanged: (selection) {
                          localeProvider.setLocale(selection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionHeader(
                icon: Icons.verified_user_outlined,
                title: 'Device Monitoring & Safety',
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Auto-monitor connected devices'),
                      subtitle: const Text(
                        'Periodically detect ADB & Fastboot state changes in the background',
                      ),
                      value: settings.autoMonitorDevices,
                      onChanged: (value) async {
                        await settings.setAutoMonitorDevices(value);
                        if (value) {
                          deviceProvider.startMonitoring();
                        } else {
                          deviceProvider.stopMonitoring();
                        }
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Confirm before flashing'),
                      subtitle: const Text(
                        'Show target device, image, and safety summary before writing boot partition',
                      ),
                      value: settings.confirmBeforeFlash,
                      onChanged: settings.setConfirmBeforeFlash,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Redact personal info in diagnostics'),
                      subtitle: const Text(
                        'Mask Windows usernames and full device serials when exporting diagnostic bundles',
                      ),
                      value: settings.redactDiagnostics,
                      onChanged: settings.setRedactDiagnostics,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Check for updates on launch'),
                      subtitle: const Text(
                        'Check GitHub releases for newer FolkTool versions',
                      ),
                      value: settings.checkUpdatesOnLaunch,
                      onChanged: settings.setCheckUpdatesOnLaunch,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionHeader(
                icon: Icons.cleaning_services_outlined,
                title: 'Storage & Maintenance',
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Clear recent files history'),
                      subtitle: const Text(
                        'Removes entries from the Recent Files list (your files on disk are not deleted)',
                      ),
                      trailing: OutlinedButton(
                        onPressed: () async {
                          final ok = await _confirmAction(
                            context,
                            title: 'Clear Recent Files?',
                            message:
                                'This only clears the history list inside FolkTool. Your boot images on disk will not be deleted.',
                            confirmLabel: 'Clear List',
                          );
                          if (!ok) return;
                          await FileService().clearRecentFiles();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recent files history cleared'),
                              ),
                            );
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: const Text('Clear session logs'),
                      subtitle: const Text(
                        'Clears in-memory operation logs for the current session',
                      ),
                      trailing: OutlinedButton(
                        onPressed: () async {
                          final ok = await _confirmAction(
                            context,
                            title: 'Clear Session Logs?',
                            message:
                                'All current in-memory log entries will be cleared.',
                            confirmLabel: 'Clear Logs',
                          );
                          if (!ok) return;
                          patchProvider.clearLogs();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Session logs cleared'),
                              ),
                            );
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: const Text('Open logs & backup folders'),
                      subtitle: const Text(
                        'View exported logs, crash-safe session logs, and stock boot backups',
                      ),
                      trailing: Wrap(
                        spacing: AppSpacing.xs,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final fs = FileService();
                              final dir = await fs.getLogsDirectory();
                              await fs.openDirectory(dir);
                            },
                            child: const Text('Logs'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final fs = FileService();
                              final dir = await fs.getBackupDirectory();
                              await fs.openDirectory(dir);
                            },
                            child: const Text('Backups'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_outlined),
                      title: const Text('Clear saved log files on disk'),
                      subtitle: const Text(
                        'Deletes archived .txt and .log files inside FolkTool/logs (stock boot backups are untouched)',
                      ),
                      trailing: OutlinedButton(
                        onPressed: () async {
                          final ok = await _confirmAction(
                            context,
                            title: 'Delete Saved Log Files?',
                            message:
                                'All saved log files in FolkTool/logs will be permanently deleted. Your boot images and backups remain untouched.',
                            confirmLabel: 'Delete Logs',
                          );
                          if (!ok) return;
                          final count = await FileService().clearSavedLogs();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  count == 0
                                      ? 'No saved log files to delete'
                                      : 'Deleted $count saved log file(s)',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Delete'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.restart_alt_rounded,
                        color: colorScheme.error,
                      ),
                      title: const Text('Reset settings to defaults'),
                      subtitle: const Text(
                        'Restores safety toggles and monitoring preferences to defaults',
                      ),
                      trailing: OutlinedButton(
                        onPressed: () async {
                          final ok = await _confirmAction(
                            context,
                            title: 'Reset All Settings?',
                            message:
                                'Restore all safety, monitoring, and diagnostic preferences to default values?',
                            confirmLabel: 'Reset',
                          );
                          if (!ok) return;
                          await settings.resetToDefaults();
                          deviceProvider.startMonitoring();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings restored to defaults'),
                              ),
                            );
                          }
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Card(
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: colorScheme.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${AppConfig.appName} v${AppConfig.appVersion} • Runs with explicit preflight checks, signed driver verification, and standard Windows security policies.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
