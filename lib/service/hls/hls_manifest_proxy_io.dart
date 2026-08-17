import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'hls_ad_filter.dart';

class HlsManifestProxy {
  static const int maxManifestBytes = 1024 * 1024;
  static const Set<String> _hlsMimeTypes = {
    'application/vnd.apple.mpegurl',
    'application/x-mpegurl',
    'audio/mpegurl',
    'audio/x-mpegurl',
  };

  final HttpClient _client;
  final Map<String, _ManifestSession> _sessions = {};
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _serverSubscription;

  HlsManifestProxy({HttpClient? client}) : _client = client ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 12);
    _client.idleTimeout = const Duration(seconds: 12);
    _client.autoUncompress = true;
  }

  Future<Uri?> prepare(Uri remoteUri, Map<String, String> headers) async {
    final fetched = await _fetch(remoteUri, headers);
    if (!fetched.isHls) return null;
    await _ensureStarted();
    final token = _randomToken();
    final session = _ManifestSession(token, Map.unmodifiable(headers));
    session.initial[fetched.finalUri.toString()] = fetched;
    _sessions[token] = session;
    return _proxyUri(token, fetched.finalUri);
  }

  Future<void> _ensureStarted() async {
    if (_server != null) return;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    _serverSubscription = server.listen(_handleRequest);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.method != 'GET' && request.method != 'HEAD') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        return;
      }
      final parts = request.uri.pathSegments;
      if (parts.length != 3 ||
          parts[0] != 'hls' ||
          parts[2] != 'manifest.m3u8') {
        request.response.statusCode = HttpStatus.notFound;
        return;
      }
      final session = _sessions[parts[1]];
      final encoded = request.uri.queryParameters['u'];
      if (session == null || encoded == null) {
        request.response.statusCode = HttpStatus.notFound;
        return;
      }
      final remote = Uri.parse(
        utf8.decode(base64Url.decode(base64Url.normalize(encoded))),
      );
      final fetched =
          session.initial.remove(remote.toString()) ??
          await _fetch(remote, session.headers);
      if (!fetched.isHls) {
        request.response.statusCode = HttpStatus.badGateway;
        return;
      }

      HlsFilterResult result;
      try {
        result = HlsAdFilter.filter(fetched.content, fetched.finalUri);
      } catch (error) {
        result = HlsFilterResult(
          content: fetched.content,
          segmentsBefore: 0,
          segmentsAfter: 0,
          changed: false,
          rolledBack: true,
          reason: 'filter-error',
        );
        _log('filter-error', fetched.finalUri, error: error);
      }
      final rewritten = _rewriteUris(
        result.content,
        fetched.finalUri,
        session.token,
        master: fetched.content.contains('#EXT-X-STREAM-INF'),
      );
      _log(
        result.reason,
        fetched.finalUri,
        before: result.segmentsBefore,
        after: result.segmentsAfter,
      );
      final bytes = utf8.encode(rewritten);
      request.response.headers
        ..contentType = ContentType(
          'application',
          'vnd.apple.mpegurl',
          charset: 'utf-8',
        )
        ..set(HttpHeaders.cacheControlHeader, 'no-store')
        ..contentLength = request.method == 'HEAD' ? 0 : bytes.length;
      if (request.method == 'GET') request.response.add(bytes);
    } on _ManifestTooLarge catch (error) {
      _log('manifest-too-large', error.uri);
      request.response.statusCode = HttpStatus.badGateway;
    } catch (error) {
      if (kDebugMode) debugPrint('[HlsAdFilter] proxy-error=$error');
      request.response.statusCode = HttpStatus.badGateway;
    } finally {
      await request.response.close();
    }
  }

  Future<_FetchedManifest> _fetch(
    Uri remoteUri,
    Map<String, String> headers,
  ) async {
    final request = await _client.getUrl(remoteUri);
    request
      ..followRedirects = true
      ..maxRedirects = 5
      ..persistentConnection = false;
    for (final entry in headers.entries) {
      final name = entry.key.toLowerCase();
      if (name == 'host' || name == 'content-length') continue;
      request.headers.set(entry.key, entry.value);
    }
    final response = await request.close();
    var finalUri = remoteUri;
    for (final redirect in response.redirects) {
      finalUri = finalUri.resolveUri(redirect.location);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.drain<void>();
      throw HttpException(
        'Manifest HTTP ${response.statusCode}',
        uri: finalUri,
      );
    }
    final mime = response.headers.contentType?.mimeType.toLowerCase();
    final isHls =
        isM3u8Path(finalUri) || (mime != null && _hlsMimeTypes.contains(mime));
    if (!isHls) {
      final subscription = response.listen(null);
      await subscription.cancel();
      return _FetchedManifest(finalUri, '', false);
    }
    final builder = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in response) {
      total += chunk.length;
      if (total > maxManifestBytes) throw _ManifestTooLarge(finalUri);
      builder.add(chunk);
    }
    return _FetchedManifest(
      finalUri,
      utf8.decode(builder.takeBytes(), allowMalformed: true),
      true,
    );
  }

  String _rewriteUris(
    String playlist,
    Uri baseUri,
    String token, {
    required bool master,
  }) {
    final lines = playlist.split(RegExp(r'\r?\n'));
    var afterStreamInfo = false;
    for (var index = 0; index < lines.length; index++) {
      final value = lines[index].trim();
      if (value.startsWith('#EXT-X-STREAM-INF')) {
        afterStreamInfo = true;
        continue;
      }
      if (value.isNotEmpty && !value.startsWith('#')) {
        final resolved = baseUri.resolve(value);
        lines[index] = master && afterStreamInfo
            ? _proxyUri(token, resolved).toString()
            : resolved.toString();
        afterStreamInfo = false;
        continue;
      }
      if (!value.contains('URI=')) continue;
      final proxyManifest =
          value.startsWith('#EXT-X-MEDIA') ||
          value.startsWith('#EXT-X-I-FRAME-STREAM-INF') ||
          value.startsWith('#EXT-X-RENDITION-REPORT');
      lines[index] = lines[index].replaceAllMapped(RegExp(r'URI="([^"]+)"'), (
        match,
      ) {
        final resolved = baseUri.resolve(match.group(1)!);
        final uri = proxyManifest && _isLikelyManifest(resolved)
            ? _proxyUri(token, resolved)
            : resolved;
        return 'URI="${uri.toString()}"';
      });
    }
    return lines.join('\n');
  }

  Uri _proxyUri(String token, Uri remoteUri) {
    final encoded = base64Url
        .encode(utf8.encode(remoteUri.toString()))
        .replaceAll('=', '');
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: _server!.port,
      pathSegments: ['hls', token, 'manifest.m3u8'],
      queryParameters: {'u': encoded},
    );
  }

  static bool isM3u8Path(Uri uri) => uri.path.toLowerCase().endsWith('.m3u8');

  static bool _isLikelyManifest(Uri uri) {
    if (isM3u8Path(uri)) return true;
    final last = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    return !last.contains('.');
  }

  void _log(String reason, Uri uri, {int? before, int? after, Object? error}) {
    if (!kDebugMode) return;
    debugPrint(
      '[HlsAdFilter] reason=$reason host=${uri.host} '
      'segments=${before ?? '-'}->${after ?? '-'}${error == null ? '' : ' error=$error'}',
    );
  }

  String _randomToken() {
    final bytes = List<int>.generate(24, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Future<void> close() async {
    _sessions.clear();
    await _serverSubscription?.cancel();
    await _server?.close(force: true);
    _server = null;
    _serverSubscription = null;
    _client.close(force: true);
  }
}

class _ManifestSession {
  final String token;
  final Map<String, String> headers;
  final Map<String, _FetchedManifest> initial = {};

  _ManifestSession(this.token, this.headers);
}

class _FetchedManifest {
  final Uri finalUri;
  final String content;
  final bool isHls;

  const _FetchedManifest(this.finalUri, this.content, this.isHls);
}

class _ManifestTooLarge implements Exception {
  final Uri uri;

  const _ManifestTooLarge(this.uri);
}
