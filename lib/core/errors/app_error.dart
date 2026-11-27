/// Structured error categories for actionable user feedback and diagnostics.
enum AppErrorCategory {
  deviceConnection,
  adb,
  fastboot,
  driver,
  file,
  imageValidation,
  compatibility,
  permission,
  network,
  download,
  extraction,
  process,
  flashing,
  application,
}

/// User-facing, actionable error model preserving technical details for logs.
class AppError implements Exception {
  final AppErrorCategory category;
  final String title;
  final String message;
  final String? reason;
  final String? affectedStage;
  final bool deviceSafe;
  final String nextSteps;
  final bool canSafelyRetry;
  final String? technicalDetails;

  const AppError({
    required this.category,
    required this.title,
    required this.message,
    this.reason,
    this.affectedStage,
    this.deviceSafe = true,
    required this.nextSteps,
    this.canSafelyRetry = true,
    this.technicalDetails,
  });

  String toClipboardText() {
    final buf = StringBuffer()
      ..writeln('[$categoryName] $title')
      ..writeln('What happened: $message');
    if (reason != null) buf.writeln('Reason: $reason');
    if (affectedStage != null) buf.writeln('Stage: $affectedStage');
    buf.writeln('Device Safe: ${deviceSafe ? 'Yes' : 'Uncertain — check device'}');
    buf.writeln('Next steps: $nextSteps');
    if (technicalDetails != null && technicalDetails!.isNotEmpty) {
      buf.writeln('Technical details:\n$technicalDetails');
    }
    return buf.toString();
  }

  String get categoryName {
    switch (category) {
      case AppErrorCategory.deviceConnection:
        return 'Device Connection';
      case AppErrorCategory.adb:
        return 'ADB';
      case AppErrorCategory.fastboot:
        return 'Fastboot';
      case AppErrorCategory.driver:
        return 'Driver';
      case AppErrorCategory.file:
        return 'File';
      case AppErrorCategory.imageValidation:
        return 'Image Validation';
      case AppErrorCategory.compatibility:
        return 'Compatibility';
      case AppErrorCategory.permission:
        return 'Permission';
      case AppErrorCategory.network:
        return 'Network';
      case AppErrorCategory.download:
        return 'Download';
      case AppErrorCategory.extraction:
        return 'Extraction';
      case AppErrorCategory.process:
        return 'Process';
      case AppErrorCategory.flashing:
        return 'Flashing';
      case AppErrorCategory.application:
        return 'Application';
    }
  }

  @override
  String toString() => '$title: $message';
}