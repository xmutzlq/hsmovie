import 'dart:convert';
import 'dart:io';

import 'package:ble_project/player/media_kit_player.dart';
import 'package:ble_project/service/hls/hls_playback_preparer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'media player value exposes the states required by the existing skin',
    () {
      const initial = MediaKitPlayerValue();
      final playing = initial.copyWith(
        state: MediaPlaybackState.started,
        duration: const Duration(minutes: 2),
        prepared: true,
      );
      expect(playing.state, MediaPlaybackState.started);
      expect(playing.prepared, isTrue);
      expect(playing.duration, const Duration(minutes: 2));
    },
  );

  test('known direct media keeps the original URL without probing', () async {
    final preparer = HlsPlaybackPreparer();
    addTearDown(preparer.close);
    const url = 'https://cdn.example.com/movie.mp4?token=redacted';
    final prepared = await preparer.prepare(url, const {'Referer': 'test'});
    expect(prepared.playbackUri, url);
    expect(prepared.originalUri, url);
    expect(prepared.filteringEnabled, isFalse);
  });

  test(
    'closing the preparer makes an issued loopback URL unavailable',
    () async {
      final upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => upstream.close(force: true));
      upstream.listen((request) async {
        request.response.headers.contentType = ContentType(
          'application',
          'vnd.apple.mpegurl',
        );
        request.response.write('#EXTM3U\n#EXTINF:10,\nvideo.ts');
        await request.response.close();
      });
      final preparer = HlsPlaybackPreparer();
      final prepared = await preparer.prepare(
        'http://127.0.0.1:${upstream.port}/index.m3u8',
        const {},
      );
      expect(prepared.filteringEnabled, isTrue);
      await preparer.close();

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 1);
      addTearDown(() => client.close(force: true));
      await expectLater(() async {
        final response = await (await client.getUrl(
          Uri.parse(prepared.playbackUri),
        )).close();
        await utf8.decoder.bind(response).join();
      }, throwsA(isA<SocketException>()));
    },
  );
}
