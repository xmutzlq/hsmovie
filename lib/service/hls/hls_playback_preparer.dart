import 'package:flutter/foundation.dart';

import 'hls_manifest_proxy.dart';

class PreparedPlayback {
  final String playbackUri;
  final String originalUri;
  final Map<String, String> headers;
  final bool filteringEnabled;
  final String? fallbackReason;

  const PreparedPlayback({
    required this.playbackUri,
    required this.originalUri,
    required this.headers,
    required this.filteringEnabled,
    this.fallbackReason,
  });
}

class HlsPlaybackPreparer {
  static const Set<String> _directExtensions = {
    '.mp4',
    '.mkv',
    '.avi',
    '.mov',
    '.flv',
    '.webm',
    '.mp3',
    '.m4a',
  };

  final HlsManifestProxy proxy;

  HlsPlaybackPreparer({HlsManifestProxy? proxy})
    : proxy = proxy ?? HlsManifestProxy();

  Future<PreparedPlayback> prepare(
    String url,
    Map<String, String> headers,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return _direct(url, headers, reason: 'unsupported-uri');
    }
    final lowerPath = uri.path.toLowerCase();
    if (_directExtensions.any(lowerPath.endsWith)) {
      return _direct(url, headers);
    }
    try {
      final localUri = await proxy.prepare(uri, headers);
      if (localUri == null) return _direct(url, headers, reason: 'not-hls');
      return PreparedPlayback(
        playbackUri: localUri.toString(),
        originalUri: url,
        headers: Map.unmodifiable(headers),
        filteringEnabled: true,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[HlsAdFilter] preparation-fallback host=${uri.host} error=$error',
        );
      }
      return _direct(url, headers, reason: 'preparation-error');
    }
  }

  PreparedPlayback _direct(
    String url,
    Map<String, String> headers, {
    String? reason,
  }) => PreparedPlayback(
    playbackUri: url,
    originalUri: url,
    headers: Map.unmodifiable(headers),
    filteringEnabled: false,
    fallbackReason: reason,
  );

  Future<void> close() => proxy.close();
}
