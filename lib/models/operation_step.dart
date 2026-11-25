/// Explicit flashing state machine phases.
enum FlashingPhase {
  idle,
  preflight,
  validation,
  preparation,
  patching,
  rebootingToFastboot,
  fastbootDetection,
  flashing,
  rebootingToSystem,
  verification,
  completed,
  failed,
  uncertain,
}

enum StepStatus {
  pending,
  inProgress,
  completed,
  failed,
}

enum StepType {
  selectFile,
  patchImage,
  saveFile,
  rebootToFastboot,
  flashImage,
  rebootDevice,
  backupBoot,
}

class OperationStep {
  final StepType type;
  final String name;
  StepStatus status;
  String? errorMessage;

  OperationStep({
    required this.type,
    required this.name,
    this.status = StepStatus.pending,
    this.errorMessage,
  });

  static List<OperationStep> getQuickPatchSteps() {
    return [
      OperationStep(type: StepType.selectFile, name: 'Select boot.img'),
      OperationStep(type: StepType.backupBoot, name: 'Backup original boot'),
      OperationStep(type: StepType.patchImage, name: 'Patch image'),
      OperationStep(type: StepType.saveFile, name: 'Save patched file'),
      OperationStep(type: StepType.rebootToFastboot, name: 'Reboot to Fastboot'),
      OperationStep(type: StepType.flashImage, name: 'Flash to device'),
      OperationStep(type: StepType.rebootDevice, name: 'Reboot complete'),
    ];
  }

  static List<OperationStep> getStepPatchSteps() {
    return [
      OperationStep(type: StepType.patchImage, name: 'Patch boot.img'),
      OperationStep(type: StepType.saveFile, name: 'Save patched file'),
      OperationStep(type: StepType.rebootToFastboot, name: 'Device enter Fastboot'),
      OperationStep(type: StepType.flashImage, name: 'Flash boot.img'),
    ];
  }
}