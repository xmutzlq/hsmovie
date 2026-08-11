import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/foundation.dart';

class DlnaCastSession extends ChangeNotifier {
  final DLNADevice device;
  final String? videoId;
  final String mediaTitle;

  PositionParser? position;
  bool isPlaying = false;
  bool isBusy = false;

  Timer? _pollTimer;
  Timer? _commandRefreshTimer;
  bool _disposed = false;
  int _commandVersion = 0;

  DlnaCastSession(this.device, {this.videoId, this.mediaTitle = ''}) {
    unawaited(refresh());
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(refresh()),
    );
  }

  Future<void> refresh() async {
    final refreshVersion = _commandVersion;
    try {
      final positionText = await device.position();
      position = PositionParser(positionText);
      _notify();
    } catch (error) {
      debugPrint('DLNA position refresh failed: $error');
    }

    try {
      final transportText = await device.getTransportInfo();
      final state = TransportInfoParser(
        transportText,
      ).CurrentTransportState.toUpperCase();
      if (refreshVersion == _commandVersion) {
        isPlaying = state == 'PLAYING' || state == 'TRANSITIONING';
        _notify();
      }
    } catch (error) {
      debugPrint('DLNA transport refresh failed: $error');
    }
  }

  Future<void> cast(String url) async {
    await _run('cast', () async {
      await device.setUrl(url);
      await device.play();
      isPlaying = true;
    });
    _refreshAfterCommand();
  }

  Future<void> play() async {
    await _run('play', () async {
      await device.play();
      isPlaying = true;
    });
    _refreshAfterCommand();
  }

  Future<void> pause() async {
    await _run('pause', () async {
      await device.pause();
      isPlaying = false;
    });
    _refreshAfterCommand();
  }

  Future<void> togglePlayback() => isPlaying ? pause() : play();

  Future<void> stop() async {
    await _run('stop', () async {
      await device.stop();
      isPlaying = false;
    });
    _refreshAfterCommand();
  }

  Future<void> seekBy(int seconds) async {
    await _run('seek:$seconds', () async {
      final current = await device.position();
      position = PositionParser(current);
      await device.seekByCurrent(current, seconds);
    });
    _refreshAfterCommand();
  }

  Future<void> _run(String command, Future<void> Function() action) async {
    _commandVersion++;
    isBusy = true;
    _notify();
    debugPrint('DLNA command $command -> ${device.info.friendlyName}');
    try {
      await action();
      debugPrint('DLNA command $command succeeded');
    } catch (error) {
      debugPrint('DLNA command $command failed: $error');
      rethrow;
    } finally {
      isBusy = false;
      _notify();
    }
  }

  void _refreshAfterCommand() {
    _commandRefreshTimer?.cancel();
    _commandRefreshTimer = Timer(
      const Duration(milliseconds: 700),
      () => unawaited(refresh()),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _pollTimer?.cancel();
    _commandRefreshTimer?.cancel();
    super.dispose();
  }
}
