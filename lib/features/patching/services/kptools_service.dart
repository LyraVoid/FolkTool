import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../core/config/app_config.dart';
import '../../../core/process/process_runner.dart';
import '../../../generated/l10n.dart';
import '../models/kp_version.dart';
import '../models/patch_result.dart';

typedef PatchLogCallback = void Function(String line);

class KpToolsService {
  final ProcessRunner _processRunner;

  KpToolsService({ProcessRunner? processRunner})
      : _processRunner = processRunner ??
            const DefaultProcessRunner(timeout: Duration(seconds: 60));

  Future<PatchResult> patchBootImage({
    required String inputPath,
    required String outputPath,
    List<String> kpmModules = const [],
    KpVersion? kpVersion,
    PatchLogCallback? onLog,
  }) async {
    final logs = <String>[];

    try {
      final kpimgPath = kpVersion?.kpimgPath ?? _getKpimgPath();

      onLog?.call(S.current.logCheckingFile);
      onLog?.call(S.current.logInputFile(inputPath));
      onLog?.call(S.current.logOutputFile(outputPath));
      onLog?.call(S.current.logKpimgPath(kpimgPath));
      onLog?.call(S.current.logKptoolsPath(AppConfig.kptoolsPath));

      if (!await File(inputPath).exists()) {
        return PatchResult.failure(
          S.current.errInputNotExist(inputPath),
          logs: logs,
        );
      }

      if (!await File(kpimgPath).exists()) {
        return PatchResult.failure(
          S.current.errKpimgNotExist(kpimgPath),
          logs: logs,
        );
      }

      if (!await File(AppConfig.kptoolsPath).exists()) {
        return PatchResult.failure(
          S.current.errKptoolsNotExist(AppConfig.kptoolsPath),
          logs: logs,
        );
      }

      final workDir = await Directory.systemTemp.createTemp('folkpatch_');
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
          return PatchResult.failure(
            S.current.errUnpackFailed(unpackResult.stderr),
            logs: logs,
          );
        }

        final kernelPath = p.join(workDir.path, 'kernel');
        if (!await File(kernelPath).exists()) {
          return PatchResult.failure(
            S.current.errKernelNotFound,
            logs: logs,
          );
        }
        onLog?.call(S.current.logUnpackSuccess(kernelPath));

        final kernelOriPath = p.join(workDir.path, 'kernel.ori');
        await File(kernelPath).copy(kernelOriPath);
        onLog?.call(S.current.logBackupKernel);

        onLog?.call(S.current.logPatchingKernel);
        final patchArgs = [
          '-p',
          '-i',
          kernelOriPath,
          '-k',
          kpimgPath,
          '-o',
          kernelPath,
        ];

        final kpmPaths = <String>[];
        for (final module in kpmModules) {
          final fileName = p.basename(module);
          final workModulePath = p.join(workDir.path, fileName);
          await File(module).copy(workModulePath);
          kpmPaths.add(fileName);
          onLog?.call(S.current.logKpmModule(module));
        }

        for (final kpmPath in kpmPaths) {
          patchArgs.addAll(['-M', kpmPath, '-N', kpmPath, '-T', 'kpm']);
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
          return PatchResult.failure(
            S.current.errPatchFailed(patchResult.stderr),
            logs: logs,
          );
        }

        if (!await File(kernelPath).exists()) {
          return PatchResult.failure(
            S.current.errOutputKernelNotFound,
            logs: logs,
          );
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
          onLog?.call(
            S.current.logRepackSuccess(
              outputPath,
              (size / 1024 / 1024).toStringAsFixed(2),
            ),
          );
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
      return PatchResult.failure(
        S.current.errPatchException(e),
        logs: logs,
      );
    }
  }

  Future<PatchResult> unpatchBootImage({
    required String inputPath,
    required String outputPath,
    PatchLogCallback? onLog,
  }) async {
    final logs = <String>[];

    try {
      final result = await _runKptools(
        ['-u', '-i', inputPath, '-o', outputPath],
        onLog: (line) {
          logs.add(line);
          onLog?.call(line);
        },
      );

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

  Future<String?> unpackBootImage(
    String inputPath, {
    PatchLogCallback? onLog,
  }) async {
    try {
      final result = await _runKptools(['unpack', inputPath], onLog: onLog);

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

  Future<String?> repackBootImage(
    String inputPath,
    String outputPath, {
    PatchLogCallback? onLog,
  }) async {
    try {
      final result = await _runKptools(
        ['repack', inputPath, '-o', outputPath],
        onLog: onLog,
      );

      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return outputPath;
      }
      return null;
    } catch (e) {
      onLog?.call(S.current.logRepackException(e));
      return null;
    }
  }

  Future<String> listPatchInfo(
    String inputPath, {
    PatchLogCallback? onLog,
  }) async {
    try {
      final result =
          await _runKptools(['-l', '-i', inputPath], onLog: onLog);
      return result.stdout.toString();
    } catch (e) {
      return S.current.logListPatchInfoFailed(e);
    }
  }

  Future<bool> checkKpimgExists() => File(_getKpimgPath()).exists();

  Future<bool> checkKptoolsExists() => File(AppConfig.kptoolsPath).exists();

  String _getKpimgPath() => AppConfig.fallbackKpimgPath;

  Future<ProcessResult> _runKptools(
    List<String> args, {
    String? workDir,
    PatchLogCallback? onLog,
  }) async {
    final executable = AppConfig.kptoolsPath;

    onLog?.call(S.current.logExecuteCmd('kptools ${args.join(' ')}'));

    final result = await _processRunner.run(
      executable,
      args,
      workingDirectory: workDir,
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
