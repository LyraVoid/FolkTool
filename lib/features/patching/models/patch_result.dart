class PatchResult {
  final bool success;
  final String? outputPath;
  final String? errorMessage;
  final List<String> logs;

  PatchResult({
    required this.success,
    this.outputPath,
    this.errorMessage,
    this.logs = const [],
  });

  PatchResult.success(this.outputPath, {this.logs = const []})
      : success = true,
        errorMessage = null;

  PatchResult.failure(this.errorMessage, {this.logs = const []})
      : success = false,
        outputPath = null;
}
