import 'dart:convert';
import 'dart:io';
import '../config/app_config.dart';

/// Metadata describing an available GitHub release.
class ReleaseInfo {
  final String version;
  final String tagName;
  final String htmlUrl;
  final String? releaseNotes;

  const ReleaseInfo({
    required this.version,
    required this.tagName,
    required this.htmlUrl,
    this.releaseNotes,
  });
}

/// Checks GitHub Releases for newer versions of FolkTool.
class UpdateService {
  final HttpClient Function()? _httpClientFactory;

  UpdateService({HttpClient Function()? httpClientFactory})
      : _httpClientFactory = httpClientFactory;

  /// Returns [ReleaseInfo] if a newer release exists on GitHub, otherwise `null`.
  Future<ReleaseInfo?> checkForUpdate({
    String currentVersion = AppConfig.appVersion,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final client = _httpClientFactory?.call() ?? HttpClient();
    client.connectionTimeout = timeout;

    try {
      final uri = Uri.https(
        'api.github.com',
        '/repos/${AppConfig.githubRepoOwner}/${AppConfig.githubRepoName}/releases/latest',
      );
      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'FolkTool/$currentVersion');

      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }

      final body = await response.transform(utf8.decoder).join().timeout(timeout);
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final tagName = (decoded['tag_name'] as String? ?? '').trim();
      final htmlUrl = (decoded['html_url'] as String? ?? '').trim();
      if (tagName.isEmpty || htmlUrl.isEmpty) {
        return null;
      }

      final normalizedLatest = normalizeVersion(tagName);
      if (!isNewerVersion(normalizedLatest, currentVersion)) {
        return null;
      }

      return ReleaseInfo(
        version: normalizedLatest,
        tagName: tagName,
        htmlUrl: htmlUrl,
        releaseNotes: decoded['body'] as String?,
      );
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Strips a leading `v` or build metadata (`+...`) from a version string.
  static String normalizeVersion(String raw) {
    var v = raw.trim();
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }
    final plusIdx = v.indexOf('+');
    if (plusIdx != -1) {
      v = v.substring(0, plusIdx);
    }
    final dashIdx = v.indexOf('-');
    if (dashIdx != -1) {
      v = v.substring(0, dashIdx);
    }
    return v;
  }

  /// Returns `true` if [latest] is strictly greater than [current].
  static bool isNewerVersion(String latest, String current) {
    final latestParts = _parseParts(normalizeVersion(latest));
    final currentParts = _parseParts(normalizeVersion(current));
    if (latestParts == null || currentParts == null) {
      return false;
    }

    final maxLen = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;
    for (var i = 0; i < maxLen; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static List<int>? _parseParts(String version) {
    if (version.isEmpty) return null;
    final segments = version.split('.');
    final parsed = <int>[];
    for (final s in segments) {
      final n = int.tryParse(s);
      if (n == null) return null;
      parsed.add(n);
    }
    return parsed;
  }
}
