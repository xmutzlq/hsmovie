import 'dart:async';
import 'dart:convert';

import 'package:ble_project/base/skin/fijkplayer_skin.dart';
import 'package:ble_project/base/skin/schema.dart';
import 'package:ble_project/model/detail/play_server_info.dart';
import 'package:ble_project/model/detail/play_url_info.dart';
import 'package:ble_project/model/player/playback_models.dart';
import 'package:ble_project/repository/playback_resolver.dart';
import 'package:fijkplayer_plus/fijkplayer_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class PlayerControllerLogic extends GetxController with SingleGetTickerProviderMixin {
  final PlayerControllerState state = PlayerControllerState();
  RxString title = "未知".obs;
  RxInt curTabIdx = 0.obs;
  RxInt curActiveIdx = 0.obs;

  RxInt curTabPageIdx = 0.obs;

  RxString currentSourceId = ''.obs;
  RxString currentSourceName = '正在解析播放源'.obs;

  var currentPlayUrl = "";

  bool get isCmsSource =>
      currentSourceId.value.isNotEmpty && currentSourceId.value != 'legacy';

  final PlaybackResolver _playbackResolver = PlaybackResolver();
  final List<PlaybackCandidate> _playbackCandidates = [];
  final Set<String> _failedCandidateUrls = {};
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _stallTimer;
  PlaybackRequest? _currentRequest;
  Duration _lastPosition = Duration.zero;
  DateTime _lastProgressAt = DateTime.now();
  Duration? _pendingResumePosition;
  int _candidateIndex = 0;
  int _recoveryAttempts = 0;
  int _playGeneration = 0;
  bool _recovering = false;
  bool _refreshedCandidates = false;

  late String videoYear;
  late String legacyMovieId;

  void onChangeVideo(int curTabIdx, int curActiveIdx) {
    this.curTabIdx.value = curTabIdx;
    this.curActiveIdx.value = curActiveIdx;
  }

  void onChangeTitle(String title) {
    this.title.value = title;
  }

  void _debugLog(Object obj) {
    if (kDebugMode) {
      final json = JsonEncoder.withIndent('  ');
      debugPrint(json.convert(obj));
    }
  }

  @override
  void onInit() {
    var map = Get.arguments;
    debugPrint('play info : ');
    // logD('${JsonEncoder.withIndent('  ').convert(map)}');
    String title = map['videoTitle'];
    videoYear = map['videoYear']?.toString() ?? '';
    legacyMovieId = map['videoId']?.toString() ?? '';
    List<PlayServerInfo> playServers = map['playServers'];
    PlayUrlInfo playUrlInfo = map['playUrlInfo'];
    List<VideoSourceFormatVideo> videoList = _buildVideoList(playServers, playUrlInfo);
    VideoSourceFormat videoEntity = VideoSourceFormat(video: videoList);
    onChangeTitle(title);
    state.videoSourceFormat = VideoSourceFormat.fromJson(videoEntity.toJson());
    state.tabController = TabController (
      length: videoEntity.video!.length,
      vsync: this,
    );
    state.tabController?.addListener(() {
      curTabPageIdx.value = state.tabController?.index ?? 0;
    });
    _startPlaybackMonitoring();
    // 这句不能省，必须有
    speed = 1.0;
    super.onInit();
  }

  Future<void> playEpisode(
    String legacyUrl,
    String episodeLabel, {
    bool force = false,
  }) async {
    final episodeKey = '$episodeLabel|$legacyUrl';
    final currentKey = _currentRequest == null
        ? ''
        : '${_currentRequest!.episodeLabel}|${_currentRequest!.legacyUrl}';
    if (!force &&
        episodeKey == currentKey &&
        currentPlayUrl.isNotEmpty &&
        state.player.state != FijkState.error &&
        state.player.state != FijkState.idle) {
      return;
    }

    _setCurrentSource(null);

    final generation = ++_playGeneration;
    final request = PlaybackRequest(
      legacyMovieId: legacyMovieId,
      title: title.value,
      year: videoYear,
      episodeLabel: episodeLabel,
      episodeNumber: PlaybackResolver.extractEpisodeNumber(episodeLabel),
      legacyUrl: legacyUrl,
    );
    final resolved = await _playbackResolver.resolve(request);
    if (generation != _playGeneration) return;

    _currentRequest = request;
    _playbackCandidates
      ..clear()
      ..addAll(resolved.candidates);
    _failedCandidateUrls.clear();
    _candidateIndex = 0;
    _recoveryAttempts = 0;
    _refreshedCandidates = false;

    if (_playbackCandidates.isEmpty) {
      currentPlayUrl = '';
      _setCurrentSource(null);
      Get.rawSnackbar(message: '未找到可播放的视频地址');
      return;
    }
    final opened = await _openCandidate(_candidateIndex, Duration.zero);
    if (!opened) await _recoverPlayback();
  }

  Future<bool> _openCandidate(int index, Duration resumeAt) async {
    if (index < 0 || index >= _playbackCandidates.length) return false;
    final candidate = _playbackCandidates[index];
    _candidateIndex = index;
    _pendingResumePosition = resumeAt > Duration.zero ? resumeAt : null;
    _lastPosition = resumeAt;
    _lastProgressAt = DateTime.now();
    _setCurrentSource(null);

    try {
      if (state.player.state != FijkState.idle &&
          state.player.state != FijkState.initialized &&
          state.player.state != FijkState.end) {
        try {
          await state.player.stop();
        } catch (_) {}
        await state.player.reset();
      } else if (state.player.state == FijkState.initialized) {
        await state.player.reset();
      }

      final headers = candidate.headers.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .join('\r\n');
      await state.player.setOption(FijkOption.formatCategory, 'headers', headers);
      await state.player.setOption(
        FijkOption.playerCategory,
        'pos-update-interval',
        500,
      );
      currentPlayUrl = candidate.url;
      await state.player.setDataSource(candidate.url, autoPlay: true);
      _setCurrentSource(candidate);
      return true;
    } catch (_) {
      _failedCandidateUrls.add(candidate.url);
      return false;
    }
  }

  void _setCurrentSource(PlaybackCandidate? candidate) {
    if (candidate == null) {
      currentSourceId.value = '';
      currentSourceName.value = '正在解析播放源';
      return;
    }

    currentSourceId.value = candidate.sourceId;
    currentSourceName.value = candidate.sourceName;
    if (kDebugMode) {
      debugPrint(
        '[Playback] source=${candidate.sourceId}, '
        'name=${candidate.sourceName}, cms=${candidate.sourceId != 'legacy'}',
      );
    }
  }

  void _startPlaybackMonitoring() {
    _positionSubscription = state.player.onCurrentPosUpdate.listen((position) {
      if (position > _lastPosition + const Duration(milliseconds: 500)) {
        _lastPosition = position;
        _lastProgressAt = DateTime.now();
        _recoveryAttempts = 0;
      }
    });
    state.player.addListener(_handlePlayerState);
    _stallTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_recovering || currentPlayUrl.isEmpty) return;
      if (state.player.state != FijkState.started) return;
      final stalledFor = DateTime.now().difference(_lastProgressAt);
      if (stalledFor >= const Duration(seconds: 12)) {
        _recoverPlayback();
      }
    });
  }

  void _handlePlayerState() {
    final pending = _pendingResumePosition;
    if (pending != null && state.player.value.prepared) {
      _pendingResumePosition = null;
      state.player.seekTo(pending.inMilliseconds);
    }
    if (state.player.state == FijkState.error && !_recovering) {
      _recoverPlayback();
    }
  }

  Future<void> _recoverPlayback() async {
    if (_recovering || _currentRequest == null || _playbackCandidates.isEmpty) {
      return;
    }
    if (_recoveryAttempts >= 4) {
      Get.rawSnackbar(message: '播放线路不可用，请手动重试');
      return;
    }

    _recovering = true;
    final resumeAt = _lastPosition;
    try {
      while (_recoveryAttempts < 4) {
        _recoveryAttempts++;
        var nextIndex = _candidateIndex;
        if (_recoveryAttempts > 1 ||
            _failedCandidateUrls.contains(
              _playbackCandidates[_candidateIndex].url,
            )) {
          _failedCandidateUrls.add(_playbackCandidates[_candidateIndex].url);
          nextIndex = _nextHealthyCandidateIndex() ?? -1;
        }
        if (nextIndex < 0 && !_refreshedCandidates) {
          _refreshedCandidates = true;
          final refreshed = await _playbackResolver.resolve(_currentRequest!);
          _playbackCandidates
            ..clear()
            ..addAll(refreshed.candidates);
          nextIndex = _nextHealthyCandidateIndex() ?? -1;
        }
        if (nextIndex < 0) break;
        if (await _openCandidate(nextIndex, resumeAt)) return;
      }
      Get.rawSnackbar(message: '没有可用的备用播放线路');
    } finally {
      _recovering = false;
      _lastProgressAt = DateTime.now();
    }
  }

  int? _nextHealthyCandidateIndex() {
    for (var index = 0; index < _playbackCandidates.length; index++) {
      if (!_failedCandidateUrls.contains(_playbackCandidates[index].url)) {
        return index;
      }
    }
    return null;
  }

  @override
  void onReady() {
    super.onReady();
  }

  ///组装资源列表
  List<VideoSourceFormatVideo> _buildVideoList(List<PlayServerInfo> playServers, PlayUrlInfo playUrlInfo) {
    Map<String, List<VideoSourceFormatVideoList>> totalVideoUrlInfoMap = _buildVideoUrlInfoList(playUrlInfo);
    List<VideoSourceFormatVideo> videoUrls = [];
    for(PlayServerInfo playServerInfo in playServers) {
      videoUrls.add(VideoSourceFormatVideo(name: playServerInfo.show, list: totalVideoUrlInfoMap.putIfAbsent(playServerInfo.from, () => [])));
    }
    return videoUrls;
  }

  String _parseUrl(String? url) {
    // debugPrint("parseUrl = $url");
    if(url != null) {
      // final decoded = Uri.decodeFull(url);
      final uri = Uri.parse(url);
      url = uri.queryParameters['v'] ?? url;
    }
    return url??"";
  }

  ///遍历所有视频来源(14个源)
  Map<String, List<VideoSourceFormatVideoList>> _buildVideoUrlInfoList(PlayUrlInfo playUrlInfo) {
    var videoUrlInfoMap = Map<String, List<VideoSourceFormatVideoList>>();
    ///优酷视频
    if(playUrlInfo.youku != null && playUrlInfo.youku!.length > 0) {
      List<VideoSourceFormatVideoList> youkuVideoUrlInfoList = [];
      playUrlInfo.youku!.forEach((element) {
        if(element.length > 1) {
          youkuVideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(youkuVideoUrlInfoList.length > 0) {
        videoUrlInfoMap['youku'] = youkuVideoUrlInfoList;
      }
    }
    ///芒果tv
    if(playUrlInfo.mgtv != null && playUrlInfo.mgtv!.length > 0) {
      List<VideoSourceFormatVideoList> mgtvVideoUrlInfoList = [];
      playUrlInfo.mgtv!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          mgtvVideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(mgtvVideoUrlInfoList.length > 0) {
        videoUrlInfoMap['mgtv'] = mgtvVideoUrlInfoList;
      }
    }
    ///TT云
    if(playUrlInfo.tt != null && playUrlInfo.tt!.length > 0) {
      List<VideoSourceFormatVideoList> ttVideoUrlInfoList = [];
      playUrlInfo.tt!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          ttVideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(ttVideoUrlInfoList.length > 0) {
        videoUrlInfoMap['tt'] = ttVideoUrlInfoList;
      }
    }
    ///腾讯资源
    if(playUrlInfo.qq != null && playUrlInfo.qq!.length > 0) {
      List<VideoSourceFormatVideoList> qqVideoUrlInfoList = [];
      playUrlInfo.qq!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          qqVideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(qqVideoUrlInfoList.length > 0) {
        videoUrlInfoMap['qq'] = qqVideoUrlInfoList;
      }
    }
    ///快播资源
    if(playUrlInfo.kbm3u8 != null && playUrlInfo.kbm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> kbm3u8VideoUrlInfoList = [];
      playUrlInfo.kbm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          kbm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(kbm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['kbm3u8'] = kbm3u8VideoUrlInfoList;
      }
    }
    ///CK资源
    if(playUrlInfo.ckm3u8 != null && playUrlInfo.ckm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> ckm3u8VideoUrlInfoList = [];
      playUrlInfo.ckm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          ckm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(ckm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['ckm3u8'] = ckm3u8VideoUrlInfoList;
      }
    }
    ///遍历奇艺资源
    if(playUrlInfo.qiyi != null && playUrlInfo.qiyi!.length > 0) {
      List<VideoSourceFormatVideoList> qiyiVideoUrlInfoList = [];
      playUrlInfo.qiyi!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          qiyiVideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(qiyiVideoUrlInfoList.length > 0) {
        videoUrlInfoMap['qiyi'] = qiyiVideoUrlInfoList;
      }
    }
    ///遍历八戒资源
    if(playUrlInfo.bjm3u8 != null && playUrlInfo.bjm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> bjm3u8VideoUrlInfoList = [];
      playUrlInfo.bjm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          bjm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(bjm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['bjm3u8'] = bjm3u8VideoUrlInfoList;
      }
    }
    ///遍历天空资源
    if(playUrlInfo.tkm3u8 != null && playUrlInfo.tkm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> tkm3u8VideoUrlInfoList = [];
      playUrlInfo.tkm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          tkm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(tkm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['tkm3u8'] = tkm3u8VideoUrlInfoList;
      }
    }
    ///遍历百度资源
    if(playUrlInfo.dbm3u8 != null && playUrlInfo.dbm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> dbm3u8VideoUrlInfoList = [];
      playUrlInfo.dbm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          dbm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(dbm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['dbm3u8'] = dbm3u8VideoUrlInfoList;
      }
    }
    ///遍历红牛资源
    if(playUrlInfo.hnm3u8 != null && playUrlInfo.hnm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> hnm3u8VideoUrlInfoList = [];
      playUrlInfo.hnm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          hnm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(hnm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['hnm3u8'] = hnm3u8VideoUrlInfoList;
      }
    }
    ///遍历北斗资源
    if(playUrlInfo.bdxm3u8 != null && playUrlInfo.bdxm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> bdxm3u8VideoUrlInfoList = [];
      playUrlInfo.bdxm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          bdxm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(bdxm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['bdxm3u8'] = bdxm3u8VideoUrlInfoList;
      }
    }
    ///遍历无尽资源
    if(playUrlInfo.wjm3u8 != null && playUrlInfo.wjm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> wjm3u8VideoUrlInfoList = [];
      playUrlInfo.wjm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          wjm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(wjm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['wjm3u8'] = wjm3u8VideoUrlInfoList;
      }
    }
    ///最快资源
    if(playUrlInfo.zkm3u8 != null && playUrlInfo.zkm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> zkm3u8VideoUrlInfoList = [];
      playUrlInfo.zkm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          zkm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(zkm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['zkm3u8'] = zkm3u8VideoUrlInfoList;
      }
    }
    ///遍历自建云资源
    if(playUrlInfo.zjm3u8 != null && playUrlInfo.zjm3u8!.length > 0) {
      List<VideoSourceFormatVideoList> zjm3u8VideoUrlInfoList = [];
      playUrlInfo.zjm3u8!.forEach((element) {
        if(element.length > 1) {
          _parseUrl(element[1]);
          zjm3u8VideoUrlInfoList.add(VideoSourceFormatVideoList(url: _parseUrl(element[1]), name: element[0]));
        }
      });
      if(zjm3u8VideoUrlInfoList.length > 0) {
        videoUrlInfoMap['zjm3u8'] = zjm3u8VideoUrlInfoList;
      }
    }
    return videoUrlInfoMap;
  }

  @override
  void onClose() {
    _stallTimer?.cancel();
    _positionSubscription?.cancel();
    state.player.removeListener(_handlePlayerState);
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    state.player.dispose();
    state.tabController?.dispose();
  }
}
