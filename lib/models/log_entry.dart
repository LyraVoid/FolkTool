import 'app_error.dart';

enum LogLevel {
  info,
  success,
  warning,
  error,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? operationId;
  final String? deviceSerial;
  final String? stage;
  final AppErrorCategory? category;
  final String? technicalDetails;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.operationId,
    this.deviceSerial,
    this.stage,
    this.category,
    this.technicalDetails,
  });

  String get levelText {
    switch (level) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.success:
        return 'SUCCESS';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String toFormattedString() {
    final timeStr = timestamp.toString().substring(0, 19);
    final ctx = <String>[
      if (operationId != null) 'op:$operationId',
      if (stage != null) stage!,
      if (deviceSerial != null) deviceSerial!,
    ];
    final ctxPart = ctx.isEmpty ? '' : ' (${ctx.join(' | ')})';
    return '[$timeStr] [$levelText]$ctxPart $message';
  }
}