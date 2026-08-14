import 'dart:convert';
import 'dart:io';

import 'package:ble_project/service/hls/hls_playback_preparer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer upstream;
  late HlsPlaybackPreparer preparer;
  final receivedHeaders = <String>[];

  setUp(() async {
    upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    upstream.listen((request) async {
      receivedHeaders.add(request.headers.value('X-Playback-Test') ?? '');
      request.response.headers.contentType = ContentType(
        'application',
        'vnd.apple.mpegurl',
      );
      if (request.uri.path == '/master') {
        request.response.write(
          '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=1000\nchild.m3u8',
        );
      } else if (request.uri.path == '/child.m3u8') {
        request.response.write('''#EXTM3U
#EXTINF:10,
good.ts
#EXTINF:10,
https://ads.example.net/ad.ts
#EXT-X-ENDLIST''');
      } else if (request.uri.path == '/large') {
        request.response.write(
          '#EXTM3U\n${List<String>.filled(220000, 'a.ts').join('\n')}',
        );
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    });
    preparer = HlsPlaybackPreparer();
  });

  tearDown(() async {
    await preparer.close();
    await upstream.close(force: true);
  });

  test('detects extensionless HLS and proxies nested manifests only', () async {
    final remote = 'http://127.0.0.1:${upstream.port}/master';
    final prepared = await preparer.prepare(remote, const {
      'X-Playback-Test': 'present',
    });
    expect(prepared.filteringEnabled, isTrue);
    expect(Uri.parse(prepared.playbackUri).host, '127.0.0.1');
    expect(prepared.originalUri, remote);

    final master = await _get(prepared.playbackUri);
    final childUrl = master
        .split('\n')
        .firstWhere((line) => line.startsWith('http://127.0.0.1'));
    final child = await _get(childUrl);

    expect(child, contains('http://127.0.0.1:${upstream.port}/good.ts'));
    expect(child, isNot(contains('ads.example.net')));
    expect(receivedHeaders, everyElement('present'));
  });

  test('fails open when a manifest exceeds one MiB', () async {
    final remote = 'http://127.0.0.1:${upstream.port}/large';
    final prepared = await preparer.prepare(remote, const {});
    expect(prepared.filteringEnabled, isFalse);
    expect(prepared.playbackUri, remote);
    expect(prepared.fallbackReason, 'preparation-error');
  });
}

Future<String> _get(String url) async {
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(Uri.parse(url))).close();
    expect(response.statusCode, HttpStatus.ok);
    return await utf8.decoder.bind(response).join();
  } finally {
    client.close(force: true);
  }
}
