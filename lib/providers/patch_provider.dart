import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../generated/l10n.dart';
import 'device_provider.dart';
import 'version_provider.dart';

enum PatchOperationState {
  idle,
  running,
  completed,
  failed,
  cancelled,
}

class PatchProvider extends ChangeNotifier {
  final KpToolsService _kptoolsService = KpToolsService();
  final FileService _fileService = FileService();
  final Uuid _uuid = const Uuid();
  
  String? _selectedFilePath;
  String? _patchedFilePath;
  Set<String> _selectedKpmModules = {};
  List<OperationStep> _steps = [];
  int _currentStepIndex = -1;
  PatchOperationState _operationState = PatchOperationState.idle;
  List<LogEntry> _logs = [];
  String? _errorMessage;
  bool _isCancelling = false;
  String _operationId = '';
  
  String? get selectedFilePath => _selectedFilePath;
  String? get patchedFilePath => _patchedFilePath;
  Set<String> get selectedKpmModules => Set.unmodifiable(_selectedKpmModules);
  List<OperationStep> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  PatchOperationState get operationState => _operationState;
  List<LogEntry> get logs => _logs;
  String? get errorMessage => _errorMessage;
  String get operationId => _operationId;
  bool get isRunning => _operationState == PatchOperationState.running;
  bool get isCompleted => _operationState == PatchOperationState.completed;
  bool get isFailed => _operationState == PatchOperationState.failed;
  double get progress => _steps.isEmpty ? 0 : (_currentStepIndex + 1) / _steps.length;
  
  void setSelectedFile(String path) {
    _selectedFilePath = path;
    _patchedFilePath = null;
    _operationState = PatchOperationState.idle;
    _logs.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void setKpmModules(Set<String> modules) {
    _selectedKpmModules = Set.from(modules);
    notifyListeners();
  }

  void addKpmModule(String path) {
    _selectedKpmModules.add(path);
    notifyListeners();
  }

  void removeKpmModule(String path) {
    _selectedKpmModules.remove(path);
    notifyListeners();
  }

  void clearKpmModules() {
    _selectedKpmModules.clear();
    notifyListeners();
  }

  void _addLog(LogLevel level, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );
    _logs.add(entry);
    debugPrint(entry.toFormattedString());
    notifyListeners();
  }

  void _updateStepStatus(int index, StepStatus status, {String? errorMessage}) {
    if (index >= 0 && index < _steps.length) {
      _steps[index].status = status;
      _steps[index].errorMessage = errorMessage;
      notifyListeners();
    }
  }

  Future<void> startQuickPatch(
    DeviceProvider deviceProvider,
    VersionProvider versionProvider,
  ) async {
    if (_selectedFilePath == null) {
      _errorMessage = S.current.errSelectBootFirst;
      notifyListeners();
      return;
    }
    
    _operationId = _uuid.v4();
    _operationState = PatchOperationState.running;
    _steps = OperationStep.getQuickPatchSteps();
    _currentStepIndex = -1;
    _logs.clear();
    _errorMessage = null;
    _isCancelling = false;
    notifyListeners();
    
    try {
      _currentStepIndex = 0;
      
      _updateStepStatus(0, StepStatus.completed);
      
      if (_isCancelling) {
        _operationState = PatchOperationState.cancelled;
        notifyListeners();
        return;
      }
      
      _currentStepIndex = 1;
      _updateStepStatus(1, StepStatus.inProgress);
      _addLog(LogLevel.info, S.current.logBackingUpBoot);
      
      final backupDir = await _fileService.getBackupDirectory();
      final timestamp = DateTime.now().toString().replaceAll(':', '-').split('.').first;
      final backupPath = p.join(backupDir, 'boot_backup_$timestamp.img');
      
      if (deviceProvider.hasFastbootDevice) {
        final backupSuccess = await deviceProvider.backupBoot(
          backupPath,
          onLog: (line) => _addLog(LogLevel.info, line),
        );
        if (backupSuccess) {
          _addLog(LogLevel.success, S.current.logBackupComplete(backupPath));
          _updateStepStatus(1, StepStatus.completed);
        } else {
          _addLog(LogLevel.warning, S.current.logBackupFailed);
          _updateStepStatus(1, StepStatus.completed);
        }
      } else {
        _addLog(LogLevel.warning, S.current.logDeviceNotFastboot);
        _updateStepStatus(1, StepStatus.completed);
      }
      
      if (_isCancelling) {
        _operationState = PatchOperationState.cancelled;
        notifyListeners();
        return;
      }
      
      _currentStepIndex = 2;
      _updateStepStatus(2, StepStatus.inProgress);
      _addLog(LogLevel.info, S.current.logPatchingBoot);
      
      final outputDir = await _fileService.getOutputDirectory();
      _patchedFilePath = p.join(outputDir, 'boot_patched_$timestamp.img');
      
      final patchResult = await _kptoolsService.patchBootImage(
        inputPath: _selectedFilePath!,
        outputPath: _patchedFilePath!,
        kpmModules: _selectedKpmModules.toList(),
        kpVersion: versionProvider.selectedVersion,
        onLog: (line) => _addLog(LogLevel.info, line),
      );
      
      if (!patchResult.success) {
        _updateStepStatus(2, StepStatus.failed, errorMessage: patchResult.errorMessage);
        _operationState = PatchOperationState.failed;
        _errorMessage = patchResult.errorMessage;
        notifyListeners();
        return;
      }
      
      _addLog(LogLevel.success, S.current.logPatchComplete(_patchedFilePath!));
      _updateStepStatus(2, StepStatus.completed);
      
      if (_isCancelling) {
        _operationState = PatchOperationState.cancelled;
        notifyListeners();
        return;
      }
      
      _currentStepIndex = 3;
      _updateStepStatus(3, StepStatus.inProgress);
      _addLog(LogLevel.info, S.current.logSavingFile);
      
      final savedPath = await _fileService.savePatchedImage(
        _patchedFilePath!,
        customName: 'boot_patched_$timestamp.img',
      );
      _addLog(LogLevel.success, S.current.logFileSaved(savedPath));
      _updateStepStatus(3, StepStatus.completed);
      
      if (_isCancelling) {
        _operationState = PatchOperationState.cancelled;
        notifyListeners();
        return;
      }
      
      _currentStepIndex = 4;
      _updateStepStatus(4, StepStatus.inProgress);
      
      if (!deviceProvider.hasAdbDevice) {
        _addLog(LogLevel.warning, S.current.logNoAdbDevice);
        
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(seconds: 2));
          if (_isCancelling) {
            _operationState = PatchOperationState.cancelled;
            notifyListeners();
            return;
          }
          await deviceProvider.refreshDevices();
          if (deviceProvider.hasFastbootDevice) {
            break;
          }
        }
      } else {
        _addLog(LogLevel.info, S.current.logRebootingToFastboot);
        final rebootSuccess = await deviceProvider.rebootToFastboot();
        if (!rebootSuccess) {
          _addLog(LogLevel.warning, S.current.logAutoRebootFailed);
        }
      }
      
      if (!deviceProvider.hasFastbootDevice) {
        final found = await deviceProvider.waitForFastboot();
        if (!found) {
          _updateStepStatus(4, StepStatus.failed, errorMessage: S.current.logWaitFastbootTimeout);
          _operationState = PatchOperationState.failed;
          _errorMessage = S.current.logWaitFastbootTimeout;
          notifyListeners();
          return;
        }
      }
      
      _addLog(LogLevel.success, S.current.logDeviceInFastboot);
      _updateStepStatus(4, StepStatus.completed);
      
      if (_isCancelling) {
        _operationState = PatchOperationState.cancelled;
        notifyListeners();
        return;
      }
      
      _currentStepIndex = 5;
      _updateStepStatus(5, StepStatus.inProgress);
      _addLog(LogLevel.info, S.current.logFlashingBoot);
      
      final flashSuccess = await deviceProvider.flashBoot(
        _patchedFilePath!,
        onLog: (line) => _addLog(LogLevel.info, line),
      );
      
      if (!flashSuccess) {
        _updateStepStatus(5, StepStatus.failed, errorMessage: S.current.logFlashFailed);
        _operationState = PatchOperationState.failed;
        _errorMessage = S.current.errFlashBootFailed;
        notifyListeners();
        return;
      }
      
      _addLog(LogLevel.success, S.current.logFlashSuccess);
      _updateStepStatus(5, StepStatus.completed);
      
      if (_isCancelling) {
        _operationState = PatchOperationState.cancelled;
        notifyListeners();
        return;
      }
      
      _currentStepIndex = 6;
      _updateStepStatus(6, StepStatus.inProgress);
      _addLog(LogLevel.info, S.current.logRebootingDevice);
      
      await Future.delayed(const Duration(seconds: 2));
      final rebootSuccess = await deviceProvider.rebootDevice(
        onLog: (line) => _addLog(LogLevel.info, line),
      );
      
      if (rebootSuccess) {
        _addLog(LogLevel.success, S.current.logRebootSuccess);
      } else {
        _addLog(LogLevel.warning, S.current.logAutoRebootFailed2);
      }
      _updateStepStatus(6, StepStatus.completed);
      
      _operationState = PatchOperationState.completed;
      _addLog(LogLevel.success, S.current.logOneClickComplete);
      notifyListeners();
      
    } catch (e) {
      _operationState = PatchOperationState.failed;
      _errorMessage = e.toString();
      _addLog(LogLevel.error, S.current.logOperationError(e));
      notifyListeners();
    }
  }

  Future<bool> patchOnly(VersionProvider versionProvider) async {
    if (_selectedFilePath == null) {
      _errorMessage = S.current.errSelectBootFirst;
      notifyListeners();
      return false;
    }
    
    _operationState = PatchOperationState.running;
    _logs.clear();
    _errorMessage = null;
    notifyListeners();
    
    _addLog(LogLevel.info, S.current.logStartPatching);
    
    try {
      final timestamp = DateTime.now().toString().replaceAll(':', '-').split('.').first;
      final outputDir = await _fileService.getOutputDirectory();
      _patchedFilePath = p.join(outputDir, 'boot_patched_$timestamp.img');
      
      final result = await _kptoolsService.patchBootImage(
        inputPath: _selectedFilePath!,
        outputPath: _patchedFilePath!,
        kpmModules: _selectedKpmModules.toList(),
        kpVersion: versionProvider.selectedVersion,
        onLog: (line) => _addLog(LogLevel.info, line),
      );
      
      if (result.success) {
        _operationState = PatchOperationState.completed;
        _addLog(LogLevel.success, S.current.logPatchComplete(_patchedFilePath!));
        notifyListeners();
        return true;
      } else {
        _operationState = PatchOperationState.failed;
        _errorMessage = result.errorMessage;
        _addLog(LogLevel.error, S.current.logPatchFailed(result.errorMessage ?? ''));
        notifyListeners();
        return false;
      }
    } catch (e) {
      _operationState = PatchOperationState.failed;
      _errorMessage = e.toString();
      _addLog(LogLevel.error, S.current.logPatchException(e));
      notifyListeners();
      return false;
    }
  }

  void cancelOperation() {
    _isCancelling = true;
    _addLog(LogLevel.warning, S.current.logCancelling);
    notifyListeners();
  }

  void reset() {
    _selectedFilePath = null;
    _patchedFilePath = null;
    _selectedKpmModules.clear();
    _steps = [];
    _currentStepIndex = -1;
    _operationState = PatchOperationState.idle;
    _logs.clear();
    _errorMessage = null;
    _isCancelling = false;
    notifyListeners();
  }

  Future<String> exportLogs() async {
    final content = _logs.map((e) => e.toFormattedString()).join('\n');
    return await _fileService.saveLogFile(content);
  }
}
