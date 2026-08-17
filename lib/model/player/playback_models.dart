class CmsSourceConfig {
  final String id;
  final String name;
  final String api;
  final int priority;
  final Map<String, String> headers;

  const CmsSourceConfig({
    required this.id,
    required this.name,
    required this.api,
    required this.priority,
    this.headers = const {},
  });
}

class CmsSearchResult {
  final CmsSourceConfig source;
  final String mediaId;
  final String title;
  final String year;
  final Map<String, dynamic>? detailData;

  const CmsSearchResult({
    required this.source,
    required this.mediaId,
    required this.title,
    required this.year,
    this.detailData,
  });
}

class PlaybackRequest {
  final String legacyMovieId;
  final String title;
  final String year;
  final String episodeLabel;
  final int? episodeNumber;
  final String legacyUrl;

  const PlaybackRequest({
    required this.legacyMovieId,
    required this.title,
    required this.year,
    required this.episodeLabel,
    required this.legacyUrl,
    this.episodeNumber,
  });
}

class PlaybackCandidate {
  final String sourceId;
  final String sourceName;
  final String url;
  final Map<String, String> headers;

  const PlaybackCandidate({
    required this.sourceId,
    required this.sourceName,
    required this.url,
    this.headers = const {},
  });
}

class ResolvedPlayback {
  final PlaybackRequest request;
  final List<PlaybackCandidate> candidates;

  const ResolvedPlayback({required this.request, required this.candidates});

  bool get fromCms =>
      candidates.any((candidate) => candidate.sourceId != 'legacy');
}
