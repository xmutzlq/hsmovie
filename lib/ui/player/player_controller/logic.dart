import 'package:ble_project/base/skin/fijkplayer_skin.dart';
import 'package:ble_project/base/skin/schema.dart';
import 'package:ble_project/model/detail/play_server_info.dart';
import 'package:ble_project/model/detail/play_url_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class PlayerControllerLogic extends GetxController with SingleGetTickerProviderMixin {
  final PlayerControllerState state = PlayerControllerState();
  RxString title = "未知".obs;
  RxInt curTabIdx = 0.obs;
  RxInt curActiveIdx = 0.obs;

  void onChangeVideo(int curTabIdx, int curActiveIdx) {
    this.curTabIdx.value = curTabIdx;
    this.curActiveIdx.value = curActiveIdx;
  }

  void onChangeTitle(String title) {
    this.title.value = title;
  }

  @override
  void onInit() {
    var map = Get.arguments;
    String title = map['videoTitle'];
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
    // 这句不能省，必须有
    speed = 1.0;
    super.onInit();
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
    debugPrint("parseUrl = $url");
    if(url != null) {
      // final decoded = Uri.decodeFull(url);
      // final uri = Uri.parse(url);
      // url = uri.queryParameters['v'];
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
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    state.player.dispose();
    state.tabController?.dispose();
  }
}
