import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/models.dart';

class RecentFileEntry {
  final String path;
  final String fileName;
  final bool exists;
  final int? sizeBytes;
  final DateTime? modifiedAt;

  const RecentFileEntry({
    required this.path,
    required this.fileName,
    required this.exists,
    this.sizeBytes,
    this.modifiedAt,
  });

  String get formattedSize {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) {
      return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class FileService {
  Future<String?> selectBootImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['img'],
      dialogTitle: 'Select boot.img',
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        await _addToRecentFiles(path);
        return path;
      }
    }
    return null;
  }

  Future<List<String>> selectKpmModules() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kpm'],
      allowMultiple: true,
      dialogTitle: 'Select KPM Modules',
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();
    }
    return [];
  }

  Future<String> getOutputDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final outputDir =
        Directory(p.join(documentsDir.path, Constants.outputDirName));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    return outputDir.path;
  }

  Future<String> getLogsDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory(p.join(documentsDir.path, Constants.logsDirName));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir.path;
  }

  Future<String> getBackupDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupDir =
        Directory(p.join(documentsDir.path, Constants.backupDirName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<String> savePatchedImage(String sourcePath,
      {String? customName}) async {
    final outputDir = await getOutputDirectory();
    final timestamp =
        DateTime.now().toString().replaceAll(':', '-').replaceAll('.', '-');
    final fileName = customName ?? 'boot_patched_$timestamp.img';
    final outputPath = p.join(outputDir, fileName);

    await File(sourcePath).copy(outputPath);
    return outputPath;
  }

  Future<String?> savePatchedImageToLocation(String sourcePath) async {
    final timestamp =
        DateTime.now().toString().replaceAll(':', '-').replaceAll('.', '-');
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Patched Image',
      fileName: 'boot_patched_$timestamp.img',
      type: FileType.custom,
      allowedExtensions: ['img'],
    );

    if (result != null) {
      await File(sourcePath).copy(result);
      return result;
    }
    return null;
  }

  Future<String> saveLogFile(String content) async {
    final logsDir = await getLogsDirectory();
    final timestamp =
        DateTime.now().toString().replaceAll(':', '-').replaceAll('.', '-');
    final fileName = 'log_$timestamp.txt';
    final outputPath = p.join(logsDir, fileName);

    await File(outputPath).writeAsString(content);
    return outputPath;
  }

  Future<List<String>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(Constants.recentFilesKey) ?? [];
  }

  /// Returns metadata for each entry in Recent Files without deleting missing files on disk.
  Future<List<RecentFileEntry>> getRecentFileDetails() async {
    final paths = await getRecentFiles();
    final entries = <RecentFileEntry>[];
    for (final path in paths) {
      final file = File(path);
      bool exists = false;
      int? size;
      DateTime? modified;
      try {
        exists = await file.exists();
        if (exists) {
          final stat = await file.stat();
          size = stat.size;
          modified = stat.modified;
        }
      } catch (_) {
        exists = false;
      }
      entries.add(RecentFileEntry(
        path: path,
        fileName: p.basename(path),
        exists: exists,
        sizeBytes: size,
        modifiedAt: modified,
      ));
    }
    return entries;
  }

  Future<void> _addToRecentFiles(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final recentFiles = await getRecentFiles();

    // Deduplicate case-insensitively on Windows paths.
    recentFiles.removeWhere(
      (existing) => existing.toLowerCase() == filePath.toLowerCase(),
    );
    recentFiles.insert(0, filePath);

    if (recentFiles.length > Constants.maxRecentFiles) {
      recentFiles.removeRange(Constants.maxRecentFiles, recentFiles.length);
    }

    await prefs.setStringList(Constants.recentFilesKey, recentFiles);
  }

  /// Removes a single entry from Recent Files history (never deletes the user's file).
  Future<void> removeRecentFile(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final recentFiles = await getRecentFiles();
    recentFiles.removeWhere(
      (existing) => existing.toLowerCase() == filePath.toLowerCase(),
    );
    await prefs.setStringList(Constants.recentFilesKey, recentFiles);
  }

  /// Clears Recent Files history in preferences (never deletes user files).
  Future<void> clearRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.recentFilesKey);
  }

  /// Opens the containing folder in Windows Explorer (or system file manager).
  Future<bool> openFileLocation(String filePath) async {
    try {
      if (Platform.isWindows) {
        final normalized = p.normalize(filePath);
        if (await File(normalized).exists()) {
          await Process.run('explorer.exe', ['/select,', normalized]);
          return true;
        }
        final dir = Directory(p.dirname(normalized));
        if (await dir.exists()) {
          await Process.run('explorer.exe', [dir.path]);
          return true;
        }
        return false;
      }
      final dir = Directory(p.dirname(filePath));
      if (!await dir.exists()) return false;
      await Process.run(
        Platform.isMacOS ? 'open' : 'xdg-open',
        [dir.path],
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  String generatePatchedFileName(String originalPath) {
    final dir = p.dirname(originalPath);
    final name = p.basenameWithoutExtension(originalPath);
    final ext = p.extension(originalPath);
    return p.join(dir, '${name}_patched$ext');
  }

  /// Creates a timestamped backup of the stock boot image before patching.
  Future<String> backupBootImage(String sourcePath) async {
    final backupDir = await getBackupDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final baseName = p.basenameWithoutExtension(sourcePath);
    final ext = p.extension(sourcePath);
    final backupPath = p.join(backupDir, '${baseName}_stock_$timestamp$ext');
    await File(sourcePath).copy(backupPath);
    return backupPath;
  }

  /// Redacts local usernames and optional device serial from diagnostic text.
  static String redactSensitiveText(String input, {String? serial}) {
    var out = input.replaceAllMapped(
      RegExp(r'([A-Za-z]:\\Users\\)([^\\/:*?"<>|\r\n]+)'),
      (m) => '${m[1]}<USER>',
    );
    out = out.replaceAllMapped(
      RegExp(r'(/home/)([^/\r\n]+)'),
      (m) => '${m[1]}<USER>',
    );
    if (serial != null && serial.trim().isNotEmpty) {
      out = out.replaceAll(serial, '<DEVICE_SERIAL>');
    }
    return out;
  }

  /// Formats a diagnostic report containing app, OS, device, and log details.
  String buildDiagnosticReport({
    required List<LogEntry> logs,
    DeviceInfo? deviceInfo,
    bool redact = false,
  }) {
    final buf = StringBuffer()
      ..writeln('=== FolkTool Diagnostic Report ===')
      ..writeln('App Version: ${Constants.appVersion}')
      ..writeln(
          'OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}');

    if (deviceInfo != null) {
      buf
        ..writeln(
            'Device Serial: ${redact ? '<DEVICE_SERIAL>' : deviceInfo.serial}')
        ..writeln('Device State: ${deviceInfo.state.name}')
        ..writeln('Device Model: ${deviceInfo.model ?? 'unknown'}')
        ..writeln('Android Version: ${deviceInfo.androidVersion ?? 'unknown'}')
        ..writeln('Kernel Version: ${deviceInfo.kernelVersion ?? 'unknown'}');
    }

    buf.writeln('\n=== Logs (${logs.length}) ===');
    for (final entry in logs) {
      final line = entry.toFormattedString();
      buf.writeln(
        redact ? redactSensitiveText(line, serial: deviceInfo?.serial) : line,
      );
    }
    return buf.toString();
  }

  /// Saves a diagnostic report to the logs directory and returns the file path.
  Future<String> exportDiagnosticBundle({
    required List<LogEntry> logs,
    DeviceInfo? deviceInfo,
    bool redact = false,
  }) async {
    final report = buildDiagnosticReport(
      logs: logs,
      deviceInfo: deviceInfo,
      redact: redact,
    );
    return saveLogFile(report);
  }
}