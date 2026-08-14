class HlsFilterResult {
  final String content;
  final int segmentsBefore;
  final int segmentsAfter;
  final bool changed;
  final bool rolledBack;
  final String reason;

  const HlsFilterResult({
    required this.content,
    required this.segmentsBefore,
    required this.segmentsAfter,
    required this.changed,
    required this.rolledBack,
    required this.reason,
  });
}

class HlsAdFilter {
  static const double _adDurationRatio = 0.70;
  static const int _adSegmentCountDifference = 2;
  static const Set<String> _adHostKeywords = {
    'adsm',
    'ads.',
    'ad-',
    'ad.',
    'doubleclick',
    'pubmatic',
    'adpush',
    'adservice',
    'adsrv',
    'advert',
    'tracking',
    'cnzz',
    'miaozhen',
    'mediav',
  };

  static HlsFilterResult filter(String playlist, Uri baseUri) {
    final lines = playlist.split(RegExp(r'\r?\n'));
    final before = _countSegments(lines);
    if (!playlist.contains('#EXTM3U')) {
      return _result(playlist, before, before, reason: 'not-hls');
    }
    if (playlist.contains('#EXT-X-STREAM-INF')) {
      return _result(playlist, before, before, reason: 'master');
    }

    final filtered = playlist.contains('#EXT-X-DISCONTINUITY')
        ? _filterSections(lines, baseUri)
        : _filterSegments(lines, baseUri);
    final after = _countSegments(filtered.split(RegExp(r'\r?\n')));
    if (!filtered.contains('#EXTM3U') || (before > 0 && after == 0)) {
      return _result(
        playlist,
        before,
        before,
        reason: 'rollback',
        rolledBack: true,
      );
    }
    return _result(
      filtered,
      before,
      after,
      reason: after < before ? 'filtered' : 'unchanged',
    );
  }

  static HlsFilterResult _result(
    String content,
    int before,
    int after, {
    required String reason,
    bool rolledBack = false,
  }) => HlsFilterResult(
    content: content,
    segmentsBefore: before,
    segmentsAfter: after,
    changed: after < before,
    rolledBack: rolledBack,
    reason: reason,
  );

  static String _filterSections(List<String> lines, Uri baseUri) {
    final header = <String>[];
    final sections = <_Section>[];
    var current = _Section();
    var inBody = false;
    String? footer;

    for (final line in lines) {
      final value = line.trim();
      if (!inBody) {
        if (value.startsWith('#EXTINF') ||
            (value.isNotEmpty && !value.startsWith('#'))) {
          inBody = true;
        } else {
          header.add(line);
          continue;
        }
      }
      if (value.startsWith('#EXT-X-ENDLIST')) {
        footer = line;
        continue;
      }
      if (value.startsWith('#EXT-X-DISCONTINUITY')) {
        if (!current.isEmpty) {
          sections.add(current);
          current = _Section();
        }
        continue;
      }
      current.lines.add(line);
      if (value.startsWith('#EXTINF')) {
        current.duration += _parseDuration(value);
      } else if (value.isNotEmpty && !value.startsWith('#')) {
        current.segmentCount++;
        current.firstUri ??= _resolve(baseUri, value);
      }
    }
    if (!current.isEmpty) sections.add(current);
    if (sections.isEmpty) return lines.join('\n');

    final drop = List<bool>.filled(sections.length, false);
    if (sections.length < 5) {
      final index = sections.indexWhere(
        (section) => _isCrossHostAd(section, baseUri),
      );
      if (index < 0) return lines.join('\n');
      drop[index] = true;
      return _joinSections(header, sections, drop, footer);
    }

    final durations = sections.map((section) => section.duration).toList()
      ..sort();
    final counts = sections.map((section) => section.segmentCount).toList()
      ..sort();
    final durationThreshold =
        durations[durations.length ~/ 2] * _adDurationRatio;
    final countThreshold =
        (counts[counts.length ~/ 2] - _adSegmentCountDifference)
            .clamp(1, 1 << 31)
            .toInt();
    var kept = 0;
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      final boundary = index == 0 || index == sections.length - 1;
      drop[index] = boundary
          ? _isCrossHostAd(section, baseUri)
          : _isAdSection(section, baseUri, durationThreshold, countThreshold);
      if (!drop[index]) kept++;
    }
    if (kept == 0) return lines.join('\n');
    return _joinSections(header, sections, drop, footer);
  }

  static String _joinSections(
    List<String> header,
    List<_Section> sections,
    List<bool> drop,
    String? footer,
  ) {
    final out = <String>[...header];
    var previousKept = false;
    for (var index = 0; index < sections.length; index++) {
      if (drop[index]) continue;
      if (previousKept) out.add('#EXT-X-DISCONTINUITY');
      out.addAll(sections[index].lines);
      previousKept = true;
    }
    if (footer != null) out.add(footer);
    return out.join('\n');
  }

  static bool _isAdSection(
    _Section section,
    Uri baseUri,
    double durationThreshold,
    int countThreshold,
  ) {
    if (_isCrossHostAd(section, baseUri)) return true;
    if (section.duration > 0 && section.duration < durationThreshold)
      return true;
    return section.duration <= 0 &&
        section.segmentCount > 0 &&
        section.segmentCount < countThreshold;
  }

  static bool _isCrossHostAd(_Section section, Uri baseUri) {
    final host = section.firstUri?.host;
    if (host == null || host.isEmpty) return false;
    if (baseUri.host.isNotEmpty &&
        host.toLowerCase() != baseUri.host.toLowerCase()) {
      return true;
    }
    final lower = host.toLowerCase();
    return _adHostKeywords.any(lower.contains);
  }

  static String _filterSegments(List<String> lines, Uri baseUri) {
    final out = <String>[];
    for (final line in lines) {
      final value = line.trim();
      if (value.isNotEmpty && !value.startsWith('#')) {
        final uri = _resolve(baseUri, value);
        if (uri != null && _isAdUri(uri, baseUri)) {
          if (out.isNotEmpty && out.last.trim().startsWith('#EXTINF')) {
            out.removeLast();
          }
          continue;
        }
      }
      out.add(line);
    }
    return out.join('\n');
  }

  static bool _isAdUri(Uri uri, Uri baseUri) {
    if (uri.host.isEmpty) return false;
    if (baseUri.host.isNotEmpty &&
        uri.host.toLowerCase() != baseUri.host.toLowerCase()) {
      return true;
    }
    final lower = uri.host.toLowerCase();
    return _adHostKeywords.any(lower.contains);
  }

  static Uri? _resolve(Uri baseUri, String value) {
    try {
      return baseUri.resolve(value);
    } catch (_) {
      return null;
    }
  }

  static double _parseDuration(String line) {
    final match = RegExp(r'^#EXTINF:([^,]+)').firstMatch(line);
    return double.tryParse(match?.group(1)?.trim() ?? '') ?? 0;
  }

  static int _countSegments(List<String> lines) => lines
      .where((line) => line.trim().isNotEmpty && !line.trim().startsWith('#'))
      .length;
}

class _Section {
  final List<String> lines = [];
  double duration = 0;
  int segmentCount = 0;
  Uri? firstUri;

  bool get isEmpty => lines.isEmpty;
}
