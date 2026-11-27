import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config/app_config.dart';
import '../core/config/app_semantic_colors.dart';
import '../core/updates/update_service.dart';
import '../features/device/providers/device_provider.dart';
import '../features/device/widgets/client_check_card.dart';
import '../features/device/widgets/device_status_card.dart';
import '../features/drivers/screens/driver_install_screen.dart';
import '../features/files/services/file_service.dart';
import '../features/patching/providers/patch_provider.dart';
import '../features/patching/screens/quick_patch_screen.dart';
import '../features/patching/screens/simple_patch_screen.dart';
import '../features/patching/screens/step_patch_screen.dart';
import '../features/settings/providers/locale_provider.dart';
import '../features/settings/providers/settings_provider.dart';
import '../features/settings/providers/theme_provider.dart';
import '../features/settings/screens/settings_screen.dart';
import '../generated/l10n.dart';

class _SelectNavIntent extends Intent {
  final int index;
  const _SelectNavIntent(this.index);
}

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  final FileService _fileService = FileService();
  final UpdateService _updateService = UpdateService();
  List<RecentFileEntry> _recentFiles = [];
  ReleaseInfo? _availableUpdate;
  int _selectedNavIndex = 0;
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final deviceProvider = context.read<DeviceProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await deviceProvider.checkDriver();
    if (settingsProvider.autoMonitorDevices) {
      deviceProvider.startMonitoring();
    } else {
      await deviceProvider.refreshDevices();
    }

    await _loadRecentFiles();
    if (settingsProvider.checkUpdatesOnLaunch) {
      _checkForUpdates();
    }
  }

  Future<void> _checkForUpdates() async {
    final release = await _updateService.checkForUpdate();
    if (!mounted || release == null) return;
    setState(() {
      _availableUpdate = release;
    });
  }

  Future<void> _loadRecentFiles() async {
    final files = await _fileService.getRecentFileDetails();
    if (mounted) {
      setState(() {
        _recentFiles = files;
      });
    }
  }

  Future<void> _confirmClearRecentFiles() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Recent Files?'),
        content: const Text(
          'This removes entries from the Recent Files list. Your actual files on disk will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _fileService.clearRecentFiles();
      await _loadRecentFiles();
    }
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  void _selectNav(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);
    if (index == 0) {
      _loadRecentFiles();
    }
  }

  Widget _buildActivePage(BuildContext context) {
    switch (_selectedNavIndex) {
      case 1:
        return const QuickPatchScreen(key: ValueKey('nav_quick'));
      case 2:
        return const StepPatchScreen(key: ValueKey('nav_step'));
      case 3:
        return const SimplePatchScreen(key: ValueKey('nav_simple'));
      case 4:
        return const DriverInstallScreen(key: ValueKey('nav_driver'));
      case 5:
        return const SettingsScreen(key: ValueKey('nav_settings'));
      default:
        return _buildDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isZh = context.select<LocaleProvider, bool>((p) => p.isZh);
    final themeMode = context.select<ThemeProvider, ThemeMode>((p) => p.themeMode);
    final colorScheme = Theme.of(context).colorScheme;

    final destinations = <NavigationRailDestination>[
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.flash_on_outlined),
        selectedIcon: const Icon(Icons.flash_on_rounded),
        label: Text(l10n.quickPatch),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.list_alt_outlined),
        selectedIcon: const Icon(Icons.list_alt_rounded),
        label: Text(l10n.stepPatch),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.build_circle_outlined),
        selectedIcon: const Icon(Icons.build_circle_rounded),
        label: Text(l10n.simplePatch),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.usb_outlined),
        selectedIcon: const Icon(Icons.usb_rounded),
        label: Text(l10n.driverInstall),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: Text('Settings'),
      ),
    ];

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.digit1, control: true):
            _SelectNavIntent(0),
        SingleActivator(LogicalKeyboardKey.digit2, control: true):
            _SelectNavIntent(1),
        SingleActivator(LogicalKeyboardKey.digit3, control: true):
            _SelectNavIntent(2),
        SingleActivator(LogicalKeyboardKey.digit4, control: true):
            _SelectNavIntent(3),
        SingleActivator(LogicalKeyboardKey.digit5, control: true):
            _SelectNavIntent(4),
        SingleActivator(LogicalKeyboardKey.comma, control: true):
            _SelectNavIntent(5),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SelectNavIntent: CallbackAction<_SelectNavIntent>(
            onInvoke: (intent) {
              _selectNav(intent.index);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1024;
              final isMedium = constraints.maxWidth >= 720;

              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.appName),
                  leading: isMedium
                      ? IconButton(
                          icon: Icon(
                            _sidebarCollapsed || !isWide
                                ? Icons.menu_open_rounded
                                : Icons.menu_rounded,
                          ),
                          tooltip: 'Toggle Navigation',
                          onPressed: () => setState(
                              () => _sidebarCollapsed = !_sidebarCollapsed),
                        )
                      : null,
                  actions: [
                    PopupMenuButton<ThemeMode>(
                      icon: Icon(_themeIcon(themeMode)),
                      tooltip: l10n.switchTheme,
                      initialValue: themeMode,
                      onSelected: (mode) =>
                          context.read<ThemeProvider>().setThemeMode(mode),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            children: [
                              const Icon(Icons.brightness_auto_outlined,
                                  size: 18),
                              const SizedBox(width: 10),
                              Text(l10n.themeSystem),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.light,
                          child: Row(
                            children: [
                              const Icon(Icons.light_mode_outlined, size: 18),
                              const SizedBox(width: 10),
                              Text(l10n.themeLight),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.dark,
                          child: Row(
                            children: [
                              const Icon(Icons.dark_mode_outlined, size: 18),
                              const SizedBox(width: 10),
                              Text(l10n.themeDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed: () =>
                          context.read<LocaleProvider>().toggleLanguage(),
                      tooltip:
                          isZh ? l10n.switchToEnglish : l10n.switchToChinese,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _selectNav(5),
                      tooltip: 'Settings (Ctrl+,)',
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: _showAboutDialog,
                      tooltip: l10n.aboutTooltip,
                    ),
                  ],
                ),
                body: Row(
                  children: [
                    if (isMedium) ...[
                      NavigationRail(
                        extended: isWide && !_sidebarCollapsed,
                        selectedIndex: _selectedNavIndex,
                        onDestinationSelected: _selectNav,
                        destinations: destinations,
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant,
                      ),
                    ],
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: _buildActivePage(context),
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: isMedium
                    ? null
                    : NavigationBar(
                        selectedIndex: _selectedNavIndex,
                        onDestinationSelected: _selectNav,
                        destinations: [
                          const NavigationDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            label: 'Home',
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.flash_on_outlined),
                            label: l10n.quickPatch,
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.list_alt_outlined),
                            label: l10n.stepPatch,
                          ),
                          const NavigationDestination(
                            icon: Icon(Icons.build_circle_outlined),
                            label: 'Local',
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.usb_outlined),
                            label: l10n.driverInstall,
                          ),
                          const NavigationDestination(
                            icon: Icon(Icons.settings_outlined),
                            label: 'Settings',
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_availableUpdate != null) ...[
                  Card(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.system_update_alt,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'New version available: ${_availableUpdate!.tagName}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => launchUrl(
                              Uri.parse(_availableUpdate!.htmlUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: const Text('Download'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Dismiss',
                            onPressed: () => setState(() {
                              _availableUpdate = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const DeviceStatusCard(),
                const ClientCheckCard(),
                const SizedBox(height: 20),
                _buildModeSelection(context),
                if (_recentFiles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        l10n.recentFiles,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _confirmClearRecentFiles,
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRecentFiles(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectMode,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildModeCard(
                  context: context,
                  title: l10n.quickPatch,
                  subtitle: l10n.quickPatchSubtitle,
                  icon: Icons.flash_on,
                  color: Colors.blue,
                  onTap: () => _selectNav(1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildModeCard(
                  context: context,
                  title: l10n.stepPatch,
                  subtitle: l10n.stepPatchSubtitle,
                  icon: Icons.list_alt,
                  color: context.semantic.success,
                  onTap: () => _selectNav(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildModeCard(
                  context: context,
                  title: l10n.simplePatch,
                  subtitle: l10n.simplePatchSubtitle,
                  icon: Icons.build_circle,
                  color: Colors.orange,
                  onTap: () => _selectNav(3),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildModeCard(
                  context: context,
                  title: l10n.driverInstall,
                  subtitle: l10n.driverInstallSubtitle,
                  icon: Icons.usb,
                  color: Colors.purple,
                  onTap: () => _selectNav(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: color.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFiles(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _recentFiles.take(5).map((entry) {
          return ListTile(
            leading: Icon(
              entry.exists
                  ? Icons.insert_drive_file_outlined
                  : Icons.broken_image_outlined,
              color: entry.exists
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.error,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    entry.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: entry.exists
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      decoration:
                          entry.exists ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: (entry.exists
                            ? colorScheme.primary
                            : colorScheme.error)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    entry.exists ? entry.formattedSize : 'Missing',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: entry.exists
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              entry.path,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.exists)
                  IconButton(
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    tooltip: 'Open File Location',
                    onPressed: () => _fileService.openFileLocation(entry.path),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: 'Remove from list',
                  onPressed: () async {
                    await _fileService.removeRecentFile(entry.path);
                    await _loadRecentFiles();
                  },
                ),
                if (entry.exists)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            onTap: entry.exists
                ? () {
                    context.read<PatchProvider>().setSelectedFile(entry.path);
                    _selectNav(1);
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This file no longer exists on disk. You can remove it from the list.',
                        ),
                      ),
                    );
                  },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _launchGitHub(BuildContext context) async {
    final l10n = S.of(context);
    final Uri url = Uri.parse('https://github.com/LyraVoid/FolkTool');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unableToOpenLink(e.toString()))),
        );
      }
    }
  }

  void _showAboutDialog() {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: ClipOval(
                    child: Image.network(
                      'http://q.qlogo.cn/headimg_dl?dst_uin=3231515355&spec=640&img_type=jpg',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 44,
                          color: colorScheme.onSurfaceVariant,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.matsuzakaYuki,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.appVersion(AppConfig.appVersion),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _launchGitHub(context),
                  icon: const Icon(Icons.link, size: 18),
                  label: Text(l10n.github),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.aboutTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.aboutDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.aboutDescription2,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: semantic.warning.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 18,
                        color: semantic.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.backupWarning,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        Text(MaterialLocalizations.of(context).okButtonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
