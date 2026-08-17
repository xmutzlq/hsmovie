import 'package:ble_project/model/player/playback_models.dart';
import 'package:ble_project/repository/cms_video_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PlaybackResolver {
  final CmsVideoApi cmsApi;
  final Dio _legacyDio;

  PlaybackResolver({CmsVideoApi? cmsApi, Dio? legacyDio})
    : cmsApi = cmsApi ?? CmsVideoApi(),
      _legacyDio =
          legacyDio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 5),
              responseType: ResponseType.plain,
              headers: kIsWeb ? const {} : const {'User-Agent': 'hsmovie/1.0'},
            ),
          );

  Future<ResolvedPlayback> resolve(PlaybackRequest request) async {
    final results = await Future.wait([
      _resolveCms(request),
      _resolveLegacy(request.legacyUrl),
    ]);
    final candidates = <PlaybackCandidate>[
      ...(results[0] as List<PlaybackCandidate>),
      if (results[1] case final PlaybackCandidate legacy) legacy,
    ];
    final seen = <String>{};
    final unique = candidates
        .where((candidate) => seen.add(candidate.url))
        .toList();
    return ResolvedPlayback(request: request, candidates: unique);
  }

  Future<List<PlaybackCandidate>> _resolveCms(PlaybackRequest request) async {
    final searchResults = await cmsApi.searchAll(request.title);
    final matches = selectMatches(searchResults, request.title, request.year);
    if (matches.isEmpty) return const [];

    final details = await Future.wait(matches.map(cmsApi.detail));
    final candidates = <PlaybackCandidate>[];
    for (var index = 0; index < matches.length; index++) {
      final detail = details[index];
      if (detail == null) continue;
      candidates.addAll(
        parseEpisodeCandidates(
          matches[index].source,
          CmsVideoApi.valueAsString(detail['vod_play_from']),
          CmsVideoApi.valueAsString(detail['vod_play_url']),
          request.episodeLabel,
          request.episodeNumber,
        ),
      );
    }
    candidates.sort((a, b) {
      final aPriority =
          cmsApi.sources
              .where((source) => source.id == a.sourceId)
              .map((source) => source.priority)
              .firstOrNull ??
          0;
      final bPriority =
          cmsApi.sources
              .where((source) => source.id == b.sourceId)
              .map((source) => source.priority)
              .firstOrNull ??
          0;
      return bPriority.compareTo(aPriority);
    });
    return candidates;
  }

  static List<CmsSearchResult> selectMatches(
    List<CmsSearchResult> results,
    String title,
    String year,
  ) {
    final normalizedTitle = normalizeTitle(title);
    final exact = results
        .where((result) => normalizeTitle(result.title) == normalizedTitle)
        .toList();
    final normalizedYear = year.trim();
    if (normalizedYear.isNotEmpty) {
      final exactSameYear = exact
          .where((result) => result.year == normalizedYear)
          .toList();
      final sourcesWithExactMatch = exactSameYear
          .map((result) => result.source.id)
          .toSet();
      final titleWithYear = '$normalizedTitle$normalizedYear';
      final suffixedSameYear = results
          .where(
            (result) =>
                result.year == normalizedYear &&
                normalizeTitle(result.title) == titleWithYear &&
                !sourcesWithExactMatch.contains(result.source.id),
          )
          .toList();
      final sameYear = [
        ..._onePerSource(exactSameYear),
        ..._onePerSource(suffixedSameYear),
      ];
      if (sameYear.isNotEmpty) return sameYear;
      return _onePerSource(
        exact.where((result) => result.year.isEmpty).toList(),
      );
    }
    if (exact.isEmpty) return const [];
    return _onePerSource(exact);
  }

  static List<CmsSearchResult> _onePerSource(List<CmsSearchResult> results) {
    final bySource = <String, List<CmsSearchResult>>{};
    for (final result in results) {
      bySource.putIfAbsent(result.source.id, () => []).add(result);
    }
    return bySource.values
        .where((items) => items.length == 1)
        .map((items) => items.first)
        .toList();
  }

  static List<PlaybackCandidate> parseEpisodeCandidates(
    CmsSourceConfig source,
    String playFrom,
    String playUrl,
    String episodeLabel,
    int? episodeNumber,
  ) {
    final fromGroups = playFrom.split(r'$$$');
    final urlGroups = playUrl.split(r'$$$');
    final candidates = <PlaybackCandidate>[];
    for (var groupIndex = 0; groupIndex < urlGroups.length; groupIndex++) {
      final entries = urlGroups[groupIndex].split('#');
      final parsed = <({String label, String url, int? number})>[];
      for (final entry in entries) {
        final separator = entry.indexOf(r'$');
        if (separator <= 0 || separator >= entry.length - 1) continue;
        final label = entry.substring(0, separator).trim();
        final url = entry.substring(separator + 1).trim();
        if (!isHttpUrl(url)) continue;
        parsed.add((
          label: label,
          url: url,
          number: extractEpisodeNumber(label),
        ));
      }
      if (parsed.isEmpty) continue;

      Iterable<({String label, String url, int? number})> selected;
      if (episodeNumber != null) {
        selected = parsed.where((entry) => entry.number == episodeNumber);
      } else {
        final requestedNumber = extractEpisodeNumber(episodeLabel);
        if (requestedNumber != null) {
          selected = parsed.where((entry) => entry.number == requestedNumber);
        } else {
          final normalizedLabel = normalizeTitle(episodeLabel);
          selected = parsed.where(
            (entry) => normalizeTitle(entry.label) == normalizedLabel,
          );
        }
      }
      if (selected.isEmpty && parsed.length == 1) selected = parsed;

      final groupName = groupIndex < fromGroups.length
          ? fromGroups[groupIndex]
          : '';
      for (final entry in selected) {
        candidates.add(
          PlaybackCandidate(
            sourceId: source.id,
            sourceName: groupName.isEmpty
                ? source.name
                : '${source.name}-$groupName',
            url: entry.url,
            headers: source.headers,
          ),
        );
      }
    }
    return candidates;
  }

  Future<PlaybackCandidate?> _resolveLegacy(String url) async {
    if (!isHttpUrl(url)) return null;
    final lowerPath = Uri.parse(url).path.toLowerCase();
    if (lowerPath.endsWith('.m3u8') || lowerPath.endsWith('.mp4')) {
      return PlaybackCandidate(sourceId: 'legacy', sourceName: '原线路', url: url);
    }
    if (kIsWeb) return null;
    try {
      final response = await _legacyDio
          .get<String>(url)
          .timeout(const Duration(seconds: 8));
      final contentType =
          response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ??
          '';
      final body = response.data ?? '';
      if (contentType.contains('mpegurl') ||
          contentType.startsWith('video/') ||
          body.trimLeft().startsWith('#EXTM3U')) {
        return PlaybackCandidate(
          sourceId: 'legacy',
          sourceName: '原线路',
          url: url,
        );
      }
      final extracted = extractMediaUrl(body);
      if (extracted == null) return null;
      return PlaybackCandidate(
        sourceId: 'legacy',
        sourceName: '原线路',
        url: extracted,
      );
    } catch (_) {
      return null;
    }
  }

  static String? extractMediaUrl(String html) {
    final patterns = [
      RegExp(r'''video_url\s*=\s*['\"]([^'\"]+)['\"]''', caseSensitive: false),
      RegExp(
        r'''https?:\\?/\\?/[^\"'<>\s]+?\.(?:m3u8|mp4)[^\"'<>\s]*''',
        caseSensitive: false,
      ),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match == null) continue;
      final raw =
          (match.groupCount > 0 ? match.group(1) : match.group(0)) ?? '';
      final url = raw
          .replaceAll(r'\/', '/')
          .replaceAll(r'\u002F', '/')
          .replaceAll('&amp;', '&');
      if (isHttpUrl(url)) return url;
    }
    return null;
  }

  static int? extractEpisodeNumber(String label) {
    final match = RegExp(r'\d+').firstMatch(label);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  static String normalizeTitle(String value) => value.toLowerCase().replaceAll(
    RegExp(r'[\s·•:：,，.。!！?？\-—_《》〈〉【】\[\]()（）]'),
    '',
  );

  static bool isHttpUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
