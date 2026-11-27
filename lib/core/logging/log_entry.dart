import 'dart:math';
import '../errors/app_error.dart';

enum LogLevel {
  info,
  success,
  warning,
  error,
}

final Random _secureRandom = Random.secure();

/// Generates an RFC 4122 version-4 UUID string using `Random.secure` without external packages.
String generateOperationId() {
  final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');
  final hex = bytes.map(hexByte).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Structured diagnostic log line captured across patching, device, and flashing steps.
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
