import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Abstraction over external process execution for testability and protective timeouts.
abstract class ProcessRunner {
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Duration? timeout,
  });
}

/// Default [ProcessRunner] backed directly by `dart:io` [Process.start] without a shell.
///
/// Streams stdout and stderr fully to release OS handles and terminates stalled
/// subprocesses when [timeout] expires.
class DefaultProcessRunner implements ProcessRunner {
  final Duration timeout;

  const DefaultProcessRunner({this.timeout = const Duration(seconds: 30)});

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? this.timeout;
    // Never invoke a shell; pass executable and argument list directly.
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: false,
    );

    final stdoutFuture = _collectBytes(process.stdout);
    final stderrFuture = _collectBytes(process.stderr);

    try {
      final results = await Future.wait<Object>([
        process.exitCode,
        stdoutFuture,
        stderrFuture,
      ]).timeout(effectiveTimeout);

      final exitCode = results[0] as int;
      final stdoutBytes = results[1] as List<int>;
      final stderrBytes = results[2] as List<int>;

      return ProcessResult(
        process.pid,
        exitCode,
        utf8.decode(stdoutBytes, allowMalformed: true),
        utf8.decode(stderrBytes, allowMalformed: true),
      );
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await Future.wait([
        stdoutFuture.catchError((_) => const <int>[]),
        stderrFuture.catchError((_) => const <int>[]),
        process.exitCode.catchError((_) => -1),
      ]);
      rethrow;
    }
  }

  Future<List<int>> _collectBytes(Stream<List<int>> stream) async {
    final buffer = <int>[];
    await for (final chunk in stream) {
      buffer.addAll(chunk);
    }
    return buffer;
  }
}
