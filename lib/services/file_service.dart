import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class FileService {
  Future<String?> selectBootImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['img'],
      dialogTitle: '选择 boot.img 文件',
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
      dialogTitle: '选择 KPM 模块文件',
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
    final outputDir = Directory(p.join(documentsDir.path, Constants.outputDirName));
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
    final backupDir = Directory(p.join(documentsDir.path, Constants.backupDirName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<String> savePatchedImage(String sourcePath, {String? customName}) async {
    final outputDir = await getOutputDirectory();
    final timestamp = DateTime.now().toString().replaceAll(':', '-').replaceAll('.', '-');
    final fileName = customName ?? 'boot_patched_$timestamp.img';
    final outputPath = p.join(outputDir, fileName);

    await File(sourcePath).copy(outputPath);
    return outputPath;
  }

  Future<String?> savePatchedImageToLocation(String sourcePath) async {
    final timestamp = DateTime.now().toString().replaceAll(':', '-').replaceAll('.', '-');
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存位置',
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
    final timestamp = DateTime.now().toString().replaceAll(':', '-').replaceAll('.', '-');
    final fileName = 'log_$timestamp.txt';
    final outputPath = p.join(logsDir, fileName);
    
    await File(outputPath).writeAsString(content);
    return outputPath;
  }

  Future<List<String>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(Constants.recentFilesKey) ?? [];
  }

  Future<void> _addToRecentFiles(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final recentFiles = await getRecentFiles();
    
    recentFiles.remove(filePath);
    recentFiles.insert(0, filePath);
    
    if (recentFiles.length > Constants.maxRecentFiles) {
      recentFiles.removeRange(Constants.maxRecentFiles, recentFiles.length);
    }
    
    await prefs.setStringList(Constants.recentFilesKey, recentFiles);
  }

  String generatePatchedFileName(String originalPath) {
    final dir = p.dirname(originalPath);
    final name = p.basenameWithoutExtension(originalPath);
    final ext = p.extension(originalPath);
    return p.join(dir, '${name}_patched$ext');
  }
}
