import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

enum MediaPlaybackState {
  idle,
  initialized,
  prepared,
  started,
  paused,
  completed,
  error,
  end,
}

class MediaKitPlayerException {
  final String? message;

  const MediaKitPlayerException([this.message]);
}

class MediaKitPlayerValue {
  final MediaPlaybackState state;
  final Duration duration;
  final bool fullScreen;
  final bool prepared;
  final MediaKitPlayerException exception;

  const MediaKitPlayerValue({
    this.state = MediaPlaybackState.idle,
    this.duration = Duration.zero,
    this.fullScreen = false,
    this.prepared = false,
    this.exception = const MediaKitPlayerException(),
  });

  MediaKitPlayerValue copyWith({
    MediaPlaybackState? state,
    Duration? duration,
    bool? fullScreen,
    bool? prepared,
    MediaKitPlayerException? exception,
  }) => MediaKitPlayerValue(
    state: state ?? this.state,
    duration: duration ?? this.duration,
    fullScreen: fullScreen ?? this.fullScreen,
    prepared: prepared ?? this.prepared,
    exception: exception ?? this.exception,
  );
}

class MediaKitPlayer extends ChangeNotifier {
  static const MethodChannel _platformControls = MethodChannel(
    'hsmovie/player_controls',
  );

  final Player player;
  late final VideoController videoController;
  final GlobalKey<VideoState> videoKey = GlobalKey<VideoState>();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  MediaKitPlayerValue _value = const MediaKitPlayerValue();
  bool _disposed = false;

  MediaKitPlayer({Player? player}) : player = player ?? Player() {
    videoController = VideoController(this.player);
    _subscriptions.addAll([
      this.player.stream.playing.listen((playing) {
        if (playing) {
          _update(state: MediaPlaybackState.started, prepared: true);
        } else if (_value.prepared &&
            _value.state != MediaPlaybackState.completed) {
          _update(state: MediaPlaybackState.paused);
        }
      }),
      this.player.stream.completed.listen((completed) {
        if (completed)
          _update(state: MediaPlaybackState.completed, prepared: true);
      }),
      this.player.stream.duration.listen((duration) {
        _update(
          duration: duration,
          state: _value.state == MediaPlaybackState.initialized
              ? MediaPlaybackState.prepared
              : null,
          prepared: true,
        );
      }),
      this.player.stream.error.listen((error) {
        _update(
          state: MediaPlaybackState.error,
          exception: MediaKitPlayerException(error),
        );
      }),
      this.player.stream.buffering.listen((_) => _notify()),
    ]);
  }

  MediaKitPlayerValue get value => _value;
  MediaPlaybackState get state => _value.state;
  Duration get currentPos => player.state.position;
  Duration get bufferPos => player.state.buffer;
  bool get isBuffering => player.state.buffering;
  double get volume => (player.state.volume / 100).clamp(0, 1);
  Stream<Duration> get onCurrentPosUpdate => player.stream.position;
  Stream<Duration> get onBufferPosUpdate => player.stream.buffer;
  Stream<bool> get onBufferStateUpdate => player.stream.buffering;

  Future<void> setDataSource(
    String url, {
    bool autoPlay = true,
    Map<String, String> headers = const {},
  }) async {
    _update(
      state: MediaPlaybackState.initialized,
      duration: Duration.zero,
      prepared: false,
      exception: const MediaKitPlayerException(),
    );
    await player.open(Media(url, httpHeaders: headers), play: autoPlay);
  }

  Future<void> start() => player.play();
  Future<void> pause() => player.pause();

  Future<void> stop() async {
    await player.stop();
    _update(state: MediaPlaybackState.end, prepared: false);
  }

  Future<void> reset() async {
    await player.stop();
    _update(
      state: MediaPlaybackState.initialized,
      duration: Duration.zero,
      prepared: false,
      exception: const MediaKitPlayerException(),
    );
  }

  Future<void> seekTo(int milliseconds) =>
      player.seek(Duration(milliseconds: milliseconds));
  Future<void> setSpeed(double speed) => player.setRate(speed);
  Future<void> setVolume(double value) =>
      player.setVolume(value.clamp(0, 1) * 100);

  Future<double> getBrightness() async {
    if (!Platform.isAndroid) return 0.5;
    try {
      return ((await _platformControls.invokeMethod<num>('getBrightness')) ??
              0.5)
          .toDouble()
          .clamp(0, 1);
    } catch (_) {
      return 0.5;
    }
  }

  Future<void> setBrightness(double value) async {
    if (!Platform.isAndroid) return;
    try {
      await _platformControls.invokeMethod<void>(
        'setBrightness',
        value.clamp(0, 1),
      );
    } catch (_) {}
  }

  Future<void> enterFullScreen() async {
    await videoKey.currentState?.enterFullscreen();
  }

  Future<void> exitFullScreen() async {
    await videoKey.currentState?.exitFullscreen();
  }

  void setFullScreen(bool value) => _update(fullScreen: value);

  void _update({
    MediaPlaybackState? state,
    Duration? duration,
    bool? fullScreen,
    bool? prepared,
    MediaKitPlayerException? exception,
  }) {
    _value = _value.copyWith(
      state: state,
      duration: duration,
      fullScreen: fullScreen,
      prepared: prepared,
      exception: exception,
    );
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(player.dispose());
    super.dispose();
  }
}
