import 'dart:io';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart' as p;
import '../config/constants.dart';
import '../models/patch_result.dart';
import '../models/kp_version.dart';
import '../generated/l10n.dart';

typedef LogCallback = void Function(String line);

class KpToolsService {
  Future<PatchResult> patchBootImage({
    required String inputPath,
    required String outputPath,
    List<String> kpmModules = const [],
    KpVersion? kpVersion,
    LogCallback? onLog,
  }) async {
    final logs = <String>[];
    
    try {
      final kpimgPath = kpVersion?.kpimgPath ?? _getKpimgPath();
      
      onLog?.call(S.current.logCheckingFile);
      onLog?.call(S.current.logInputFile(inputPath));
      onLog?.call(S.current.logOutputFile(outputPath));
      onLog?.call(S.current.logKpimgPath(kpimgPath));
      onLog?.call(S.current.logKptoolsPath(Constants.kptoolsPath));
      
      if (!await File(inputPath).exists()) {
        return PatchResult.failure(S.current.errInputNotExist(inputPath), logs: logs);
      }
      
      if (!await File(kpimgPath).exists()) {
        return PatchResult.failure(S.current.errKpimgNotExist(kpimgPath), logs: logs);
      }
      
      if (!await File(Constants.kptoolsPath).exists()) {
        return PatchResult.failure(S.current.errKptoolsNotExist(Constants.kptoolsPath), logs: logs);
      }
      
      final workDir = Directory.systemTemp.createTempSync('folkpatch_');
      onLog?.call(S.current.logWorkDir(workDir.path));
      
      try {
        onLog?.call(S.current.logCopyBoot);
        final bootImgName = p.basename(inputPath);
        final workBootImg = p.join(workDir.path, bootImgName);
        await File(inputPath).copy(workBootImg);
        onLog?.call(S.current.logCopied(workBootImg));
        
        onLog?.call(S.current.logUnpacking);
        final unpackResult = await _runKptools(
          ['unpack', workBootImg],
          workDir: workDir.path,
          onLog: (line) {
            logs.add(line);
            onLog?.call(line);
          },
        );
        
        if (unpackResult.exitCode != 0) {
          return PatchResult.failure(S.current.errUnpackFailed(unpackResult.stderr), logs: logs);
        }
        
        final kernelPath = p.join(workDir.path, 'kernel');
        if (!await File(kernelPath).exists()) {
          return PatchResult.failure(S.current.errKernelNotFound, logs: logs);
        }
        onLog?.call(S.current.logUnpackSuccess(kernelPath));
        
        final kernelOriPath = p.join(workDir.path, 'kernel.ori');
        await File(kernelPath).copy(kernelOriPath);
        onLog?.call(S.current.logBackupKernel);
        
        onLog?.call(S.current.logPatchingKernel);
        final patchArgs = [
          '-p',
          '-i', kernelOriPath,
          '-k', kpimgPath,
          '-o', kernelPath,
        ];
        
        final List<String> kpmPaths = [];
        for (final module in kpmModules) {
          final fileName = p.basename(module);
          final workModulePath = p.join(workDir.path, fileName);
          await File(module).copy(workModulePath);
          kpmPaths.add(fileName);
          onLog?.call(S.current.logKpmModule(module));
        }
        
        for (final kpmPath in kpmPaths) {
          patchArgs.addAll(['-M', kpmPath]);
          patchArgs.addAll(['-N', kpmPath]);
          patchArgs.addAll(['-T', 'kpm']);
        }
        
        final patchResult = await _runKptools(
          patchArgs,
          workDir: workDir.path,
          onLog: (line) {
            logs.add(line);
            onLog?.call(line);
          },
        );
        
        if (patchResult.exitCode != 0) {
          return PatchResult.failure(S.current.errPatchFailed(patchResult.stderr), logs: logs);
        }
        
        if (!await File(kernelPath).exists()) {
          return PatchResult.failure(S.current.errOutputKernelNotFound, logs: logs);
        }
        onLog?.call(S.current.logPatchSuccess);
        
        onLog?.call(S.current.logRepacking);
        await _runKptools(
          ['repack', workBootImg],
          workDir: workDir.path,
          onLog: (line) {
            logs.add(line);
            onLog?.call(line);
          },
        );
        
        final newBootPath = p.join(workDir.path, 'new-boot.img');
        
        if (await File(newBootPath).exists()) {
          await File(newBootPath).copy(outputPath);
          final size = await File(outputPath).length();
          onLog?.call(S.current.logRepackSuccess(outputPath, (size / 1024 / 1024).toStringAsFixed(2)));
          return PatchResult.success(outputPath, logs: logs);
        } else {
          return PatchResult.failure(
            S.current.errRepackFailed,
            logs: logs,
          );
        }
      } finally {
        try {
          await workDir.delete(recursive: true);
          onLog?.call(S.current.logCleanWorkDir);
        } catch (e) {
          onLog?.call(S.current.logCleanWorkDirFailed(e));
        }
      }
    } catch (e) {
      return PatchResult.failure(S.current.errPatchException(e), logs: logs);
    }
  }

  Future<PatchResult> unpatchBootImage({
    required String inputPath,
    required String outputPath,
    LogCallback? onLog,
  }) async {
    final logs = <String>[];
    
    try {
      final args = [
        '-u',
        '-i', inputPath,
        '-o', outputPath,
      ];
      
      final result = await _runKptools(args, onLog: (line) {
        logs.add(line);
        onLog?.call(line);
      });
      
      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return PatchResult.success(outputPath, logs: logs);
      } else {
        return PatchResult.failure(
          S.current.errPatchFailed(result.stderr),
          logs: logs,
        );
      }
    } catch (e) {
      return PatchResult.failure(S.current.errPatchException(e), logs: logs);
    }
  }

  Future<String?> unpackBootImage(String inputPath, {LogCallback? onLog}) async {
    try {
      final args = ['unpack', inputPath];
      final result = await _runKptools(args, onLog: onLog);
      
      if (result.exitCode == 0) {
        final dir = p.dirname(inputPath);
        final kernelPath = p.join(dir, 'kernel');
        if (await File(kernelPath).exists()) {
          return kernelPath;
        }
      }
      return null;
    } catch (e) {
      onLog?.call(S.current.logUnpackException(e));
      return null;
    }
  }

  Future<String?> repackBootImage(String inputPath, String outputPath, {LogCallback? onLog}) async {
    try {
      final args = ['repack', inputPath, '-o', outputPath];
      final result = await _runKptools(args, onLog: onLog);
      
      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return outputPath;
      }
      return null;
    } catch (e) {
      onLog?.call(S.current.logRepackException(e));
      return null;
    }
  }

  Future<String> listPatchInfo(String inputPath, {LogCallback? onLog}) async {
    try {
      final args = ['-l', '-i', inputPath];
      final result = await _runKptools(args, onLog: onLog);
      return result.stdout.toString();
    } catch (e) {
      return S.current.logListPatchInfoFailed(e);
    }
  }

  Future<bool> checkKpimgExists() async {
    final kpimgPath = _getKpimgPath();
    return File(kpimgPath).exists();
  }

  Future<bool> checkKptoolsExists() async {
    return File(Constants.kptoolsPath).exists();
  }

  String _getKpimgPath() {
    return Constants.kpimgPath;
  }
  
  Future<ProcessResult> _runKptools(
    List<String> args, {
    String? workDir,
    LogCallback? onLog,
  }) async {
    final executable = Constants.kptoolsPath;
    
    onLog?.call(S.current.logExecuteCmd('kptools ${args.join(' ')}'));
    
    final result = await runExecutableArguments(
      executable,
      args,
      workingDirectory: workDir,
      verbose: false,
    );
    
    if (result.stdout.toString().isNotEmpty) {
      onLog?.call(result.stdout.toString().trim());
    }
    if (result.stderr.toString().isNotEmpty) {
      onLog?.call('[STDERR] ${result.stderr}'.trim());
    }
    
    return result;
  }
}
