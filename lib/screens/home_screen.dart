import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'quick_patch_screen.dart';
import 'step_patch_screen.dart';
import 'simple_patch_screen.dart';
import 'driver_install_screen.dart';
import '../generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  List<String> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final deviceProvider = context.read<DeviceProvider>();
    
    await deviceProvider.checkDriver();
    deviceProvider.startMonitoring();
    
    await _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await _fileService.getRecentFiles();
    setState(() {
      _recentFiles = files;
    });
  }

  void _navigateToQuickPatch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuickPatchScreen()),
    );
  }

  void _navigateToStepPatch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StepPatchScreen()),
    );
  }

  void _navigateToSimplePatch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimplePatchScreen()),
    );
  }

  void _navigateToDriverInstall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriverInstallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLanguage(),
            tooltip: localeProvider.isZh ? l10n.switchToEnglish : l10n.switchToChinese,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(),
            tooltip: l10n.aboutTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const DeviceStatusCard(),
             const SizedBox(height: 24),
             const ClientCheckCard(),
             const SizedBox(height: 24),
             _buildModeSelection(context),
             const SizedBox(height: 24),
             if (_recentFiles.isNotEmpty) ...[
               Text(
                 l10n.recentFiles,
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: Colors.grey[800],
                 ),
               ),
              const SizedBox(height: 12),
              _buildRecentFiles(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelection(BuildContext context) {
    final l10n = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectMode,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                title: l10n.quickPatch,
                subtitle: l10n.quickPatchSubtitle,
                icon: Icons.flash_on,
                color: Colors.blue,
                onTap: _navigateToQuickPatch,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                title: l10n.stepPatch,
                subtitle: l10n.stepPatchSubtitle,
                icon: Icons.list_alt,
                color: Colors.green,
                onTap: _navigateToStepPatch,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                title: l10n.simplePatch,
                subtitle: l10n.simplePatchSubtitle,
                icon: Icons.build_circle,
                color: Colors.orange,
                onTap: _navigateToSimplePatch,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                title: l10n.driverInstall,
                subtitle: l10n.driverInstallSubtitle,
                icon: Icons.usb,
                color: Colors.purple,
                onTap: _navigateToDriverInstall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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

  Widget _buildRecentFiles() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _recentFiles.take(5).map((file) {
          final fileName = file.split('\\').last;
          return ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.grey[600]),
            title: Text(
              fileName,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              file,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              final patchProvider = context.read<PatchProvider>();
              patchProvider.setSelectedFile(file);
              _navigateToQuickPatch();
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _launchGitHub(BuildContext context) async {
    final l10n = S.of(context);
    final Uri url = Uri.parse('https://github.com/matsuzaka-yuki/FolkTool');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unableToOpenLink(e.toString()))),
        );
      }
    }
  }

  void _showAboutDialog() {
    final l10n = S.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.network(
                    'http://q.qlogo.cn/headimg_dl?dst_uin=3231515355&spec=640&img_type=jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 50, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.matsuzakaYuki,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.appVersion(Constants.appVersion),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _launchGitHub(context),
                icon: const Icon(Icons.link, size: 18),
                label: Text(l10n.github),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aboutTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.aboutDescription,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aboutDescription2,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.backupWarning,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
