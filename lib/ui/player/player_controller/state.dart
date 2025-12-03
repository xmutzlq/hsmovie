import 'package:ble_project/base/skin/fijkplayer_skin.dart';
import 'package:ble_project/base/skin/schema.dart';
import 'package:fijkplayer_plus/fijkplayer_plus.dart';
import 'package:flutter/material.dart';

class PlayerControllerState {
  final FijkPlayer player = FijkPlayer();
  final ShowConfigAbs showConfigAbs = PlayerShowConfig();
  VideoSourceFormat? videoSourceFormat;
  TabController? tabController;
}

// 定制UI配置项
class PlayerShowConfig implements ShowConfigAbs {
  bool drawerBtn = true;   ///是否显示剧集按钮
  bool nextBtn   = true;   ///是否显示下一集按钮
  bool speedBtn  = true;   ///是否显示速度按钮
  bool topBar    = true;   ///是否显示播放器状态栏（顶部），非系统
  bool lockBtn   = true;   ///是否显示锁按钮
  bool autoNext  = false;  ///播放完成后是否自动播放下一集，false 播放完成即暂停
  bool bottomPro = false;  ///底部吸底进度条，贴底部，类似开眼视频
  bool stateAuto = true;   ///是否自适应系统状态栏，true 会计算系统状态栏，从而加大 topBar 的高度，避免挡住播放器状态栏
}

