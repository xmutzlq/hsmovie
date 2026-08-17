import 'package:ble_project/model/player/playback_models.dart';
import 'package:ble_project/repository/cms_video_api.dart';
import 'package:ble_project/repository/playback_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

const lzi = CmsSourceConfig(
  id: 'lzi',
  name: '量子资源',
  api: 'https://example.com/lzi',
  priority: 10,
);

const wjzy = CmsSourceConfig(
  id: 'wjzy',
  name: '无尽资源',
  api: 'https://example.com/wjzy',
  priority: 8,
);

class FakeCmsVideoApi extends CmsVideoApi {
  final List<CmsSearchResult> searchResults;
  final Map<String, Map<String, dynamic>> details;

  FakeCmsVideoApi({required this.searchResults, required this.details})
    : super(sources: const [lzi, wjzy]);

  @override
  Future<List<CmsSearchResult>> searchAll(String keyword) async =>
      searchResults;

  @override
  Future<Map<String, dynamic>?> detail(CmsSearchResult result) async =>
      details['${result.source.id}:${result.mediaId}'];
}

void main() {
  group('CMS matching', () {
    test('keeps exact title and year matches from each source', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: '1',
          title: '琅琊榜',
          year: '2015',
        ),
        const CmsSearchResult(
          source: wjzy,
          mediaId: '2',
          title: '琅琊榜',
          year: '2015',
        ),
        const CmsSearchResult(
          source: lzi,
          mediaId: '3',
          title: '琅琊榜之风起长林',
          year: '2017',
        ),
      ];

      final matches = PlaybackResolver.selectMatches(results, '琅琊榜', '2015');

      expect(matches.map((item) => item.mediaId), ['1', '2']);
    });

    test('accepts a unique exact result when CMS omits the year', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: '1',
          title: '琅琊榜',
          year: '',
        ),
      ];

      final matches = PlaybackResolver.selectMatches(results, '琅琊榜', '2015');

      expect(matches.single.mediaId, '1');
    });

    test('rejects a conflicting remake year', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: '1',
          title: '测试电影',
          year: '2024',
        ),
      ];

      expect(PlaybackResolver.selectMatches(results, '测试电影', '2020'), isEmpty);
    });

    test('accepts a CMS title suffixed with the matching year', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: '2021-movie',
          title: '九门',
          year: '2021',
        ),
        const CmsSearchResult(
          source: lzi,
          mediaId: '2026-series',
          title: '九门2026',
          year: '2026',
        ),
      ];

      final matches = PlaybackResolver.selectMatches(results, '九门', '2026');

      expect(matches.map((item) => item.mediaId), ['2026-series']);
    });

    test('prefers an exact title over a suffixed title from one source', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: 'exact',
          title: '九门',
          year: '2026',
        ),
        const CmsSearchResult(
          source: lzi,
          mediaId: 'suffixed',
          title: '九门2026',
          year: '2026',
        ),
      ];

      final matches = PlaybackResolver.selectMatches(results, '九门', '2026');

      expect(matches.map((item) => item.mediaId), ['exact']);
    });

    test('rejects unrelated titles that merely contain the year', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: 'spin-off',
          title: '九门外传2026',
          year: '2026',
        ),
      ];

      expect(PlaybackResolver.selectMatches(results, '九门', '2026'), isEmpty);
    });

    test('accepts an exact CMS alias on web', () {
      final results = [
        const CmsSearchResult(
          source: lzi,
          mediaId: 'alias-match',
          title: '老九门贰',
          year: '2026',
          aliases: ['九门'],
        ),
      ];

      final matches = PlaybackResolver.selectMatches(
        results,
        '九门',
        '2026',
        allowAliases: true,
      );

      expect(matches.single.mediaId, 'alias-match');
    });
  });

  group('episode parsing', () {
    test('normalizes padded episode labels across multiple play groups', () {
      final candidates = PlaybackResolver.parseEpisodeCandidates(
        lzi,
        r'lzm3u8$$$backup',
        r'第01集$https://cdn.example.com/1.m3u8#第02集$https://cdn.example.com/2.m3u8$$$EP01$https://backup.example.com/1.m3u8',
        '第1集',
        1,
      );

      expect(candidates.map((item) => item.url), [
        'https://cdn.example.com/1.m3u8',
        'https://backup.example.com/1.m3u8',
      ]);
    });

    test('uses the only entry for a movie with different labels', () {
      final candidates = PlaybackResolver.parseEpisodeCandidates(
        lzi,
        'lzm3u8',
        r'HD中字$https://cdn.example.com/movie.m3u8',
        '正片',
        null,
      );

      expect(candidates.single.url, 'https://cdn.example.com/movie.m3u8');
    });

    test('web can fall back to episode position for non-numeric labels', () {
      final candidates = PlaybackResolver.parseEpisodeCandidates(
        lzi,
        'lzm3u8',
        r'上集$https://cdn.example.com/1.m3u8#下集$https://cdn.example.com/2.m3u8',
        '第2集',
        2,
        allowPositionFallback: true,
      );

      expect(candidates.single.url, 'https://cdn.example.com/2.m3u8');
    });
  });

  group('legacy HTML parsing', () {
    test('extracts single and double quoted video_url values', () {
      expect(
        PlaybackResolver.extractMediaUrl(
          "<script>video_url = 'https://cdn.example.com/a.m3u8'</script>",
        ),
        'https://cdn.example.com/a.m3u8',
      );
      expect(
        PlaybackResolver.extractMediaUrl(
          '<script>video_url="https://cdn.example.com/b.mp4"</script>',
        ),
        'https://cdn.example.com/b.mp4',
      );
    });

    test('decodes escaped media URLs and HTML ampersands', () {
      final result = PlaybackResolver.extractMediaUrl(
        r'{"url":"https:\/\/cdn.example.com\/a.m3u8?x=1&amp;y=2"}',
      );

      expect(result, 'https://cdn.example.com/a.m3u8?x=1&y=2');
    });

    test('does not return a normal HTML page URL', () {
      expect(
        PlaybackResolver.extractMediaUrl('<html><body>no video</body></html>'),
        isNull,
      );
    });
  });

  test(
    'resolved CMS candidates are ordered before the legacy direct URL',
    () async {
      final result = const CmsSearchResult(
        source: lzi,
        mediaId: '1',
        title: '九门2026',
        year: '2026',
      );
      final resolver = PlaybackResolver(
        cmsApi: FakeCmsVideoApi(
          searchResults: [result],
          details: {
            'lzi:1': {
              'vod_play_from': 'lzm3u8',
              'vod_play_url': r'第01集$https://cdn.example.com/1.m3u8',
            },
          },
        ),
      );

      final resolved = await resolver.resolve(
        const PlaybackRequest(
          legacyMovieId: '275970',
          title: '九门',
          year: '2026',
          episodeLabel: '第1集',
          episodeNumber: 1,
          legacyUrl: 'https://legacy.example.com/1.m3u8',
        ),
      );

      expect(resolved.fromCms, isTrue);
      expect(resolved.candidates.map((item) => item.sourceId), [
        'lzi',
        'legacy',
      ]);
    },
  );

  test('web fallback fields can be parsed as episode candidates', () {
    final candidates = PlaybackResolver.parseEpisodeCandidates(
      lzi,
      'http',
      r'第01集$https://download.example.com/1.mp4#第02集$https://download.example.com/2.mp4',
      '第1集',
      1,
    );

    expect(candidates.single.url, 'https://download.example.com/1.mp4');
  });

  test(
    'reports a missing CMS title when no candidate can be resolved',
    () async {
      final resolver = PlaybackResolver(
        cmsApi: FakeCmsVideoApi(searchResults: const [], details: const {}),
      );

      final resolved = await resolver.resolve(
        const PlaybackRequest(
          legacyMovieId: '1',
          title: '不存在的影片',
          year: '2026',
          episodeLabel: '第1集',
          episodeNumber: 1,
          legacyUrl: '',
        ),
      );

      expect(resolved.candidates, isEmpty);
      expect(resolved.issue, PlaybackResolutionIssue.cmsTitleNotFound);
    },
  );
}
