import 'dart:io';
import 'package:process_run/process_run.dart';

/// Abstraction over external process execution for testability.
abstract class ProcessRunner {
  Future<ProcessResult> run(String executable, List<String> arguments);
}

/// Default [ProcessRunner] backed by `process_run`.
class DefaultProcessRunner implements ProcessRunner {
  const DefaultProcessRunner();

  @override
  Future<ProcessResult> run(String executable, List<String> arguments) {
    return runExecutableArguments(executable, arguments, verbose: false);
  }
}
