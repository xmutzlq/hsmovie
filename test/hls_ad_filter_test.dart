import 'package:ble_project/service/hls/hls_ad_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = Uri.parse('https://video.example.com/path/index.m3u8');

  test('leaves master playlists unchanged', () {
    const input = '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=1\nchild.m3u8';
    final result = HlsAdFilter.filter(input, base);
    expect(result.content, input);
    expect(result.reason, 'master');
  });

  test('removes an internal section shorter than the median threshold', () {
    const input = '''#EXTM3U
#EXTINF:100,
s1.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s2.ts
#EXT-X-DISCONTINUITY
#EXTINF:10,
ad.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s3.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s4.ts
#EXT-X-ENDLIST''';
    final result = HlsAdFilter.filter(input, base);
    expect(result.content, isNot(contains('ad.ts')));
    expect(result.segmentsBefore, 5);
    expect(result.segmentsAfter, 4);
    expect(result.content.split('#EXT-X-DISCONTINUITY').length - 1, 3);
  });

  test('protects short boundary sections from duration filtering', () {
    const input = '''#EXTM3U
#EXTINF:5,
intro.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s1.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s2.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s3.ts
#EXT-X-DISCONTINUITY
#EXTINF:5,
outro.ts''';
    final result = HlsAdFilter.filter(input, base);
    expect(result.content, contains('intro.ts'));
    expect(result.content, contains('outro.ts'));
  });

  test('does not duration-filter fewer than five sections', () {
    const input = '''#EXTM3U
#EXTINF:100,
s1.ts
#EXT-X-DISCONTINUITY
#EXTINF:5,
short.ts
#EXT-X-DISCONTINUITY
#EXTINF:100,
s2.ts''';
    final result = HlsAdFilter.filter(input, base);
    expect(result.content, input);
  });

  test('removes cross-host segments and their EXTINF line', () {
    const input = '''#EXTM3U
#EXTINF:10,
good.ts
#EXTINF:10,
https://ads.example.net/ad.ts
#EXTINF:10,
end.ts''';
    final result = HlsAdFilter.filter(input, base);
    expect(result.content, isNot(contains('ads.example.net')));
    expect(result.segmentsAfter, 2);
    expect(RegExp('#EXTINF').allMatches(result.content), hasLength(2));
  });

  test('rolls back when every segment would be removed', () {
    const input = '''#EXTM3U
#EXTINF:10,
https://ads.example.net/a.ts
#EXTINF:10,
https://tracking.example.net/b.ts''';
    final result = HlsAdFilter.filter(input, base);
    expect(result.content, input);
    expect(result.rolledBack, isTrue);
  });
}
