import 'dart:io';
import 'package:process_run/process_run.dart';

/// Abstraction over external process execution for testability and timeouts.
abstract class ProcessRunner {
  Future<ProcessResult> run(String executable, List<String> arguments);
}

/// Default [ProcessRunner] backed by `process_run` with a protective timeout.
class DefaultProcessRunner implements ProcessRunner {
  final Duration timeout;

  const DefaultProcessRunner({this.timeout = const Duration(seconds: 30)});

  @override
  Future<ProcessResult> run(String executable, List<String> arguments) {
    // Never invoke a shell; pass executable and argument list directly.
    return runExecutableArguments(executable, arguments, verbose: false)
        .timeout(timeout);
  }
}