import 'package:ble_project/base/skin/fijkplayer_skin.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:fijkplayer_plus/fijkplayer_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class PlayerControllerPage extends StatelessWidget {
  final logic = Get.find<PlayerControllerLogic>();
  final state = Get.find<PlayerControllerLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FijkView(
          height: 260,
          color: Colors.black,
          fit: FijkFit.cover,
          player: logic.state.player,
          panelBuilder: (
            FijkPlayer player,
            FijkData data,
            BuildContext context,
            Size viewSize,
            Rect texturePos,
          ) {
            /// 使用自定义的布局
            return Obx(() => CustomFijkPanel (
              player: player,
              viewSize: viewSize,
              texturePos: texturePos,
              pageContent: context,
              /// 标题 当前页面顶部的标题部分
              playerTitle: logic.title.value,
              /// 当前视频改变钩子
              onChangeVideo: logic.onChangeVideo,
              /// 当前视频源tabIndex
              curTabIdx: logic.curTabIdx.value,
              /// 当前视频源activeIndex
              curActiveIdx: logic.curActiveIdx.value,
              /// 显示的配置
              showConfig: logic.state.showConfigAbs,
              /// json格式化后的视频数据
              videoFormat: logic.state.videoSourceFormat,
              /// tabController
              tabController: logic.state.tabController!,
            ));
          },
        ),
        // 请不要使用同一个tabbar，否则会卡顿，原因是数据更新导致整体重新绘制，
        // 可以使用_curTabIdx和_curActiveIdx手动渲染其他类似组件，判断
        Container(
          child: Expanded(
            child: buildPlayDrawer(),
          ),
        ),
        Container(
          color: commBgColor,
          child: Text(
              '当前tabIdx : ${logic.curTabIdx.toString()} 当前activeIdx : ${logic.curActiveIdx.toString()}'),
        )
      ],
    );
  }

  /// build 剧集
  Widget buildPlayDrawer() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(24),
        child: AppBar(
          backgroundColor: commBgColor,
          automaticallyImplyLeading: false,
          primary: false,
          elevation: 0,
          title: TabBar(
            indicatorColor: appThemeData.primaryColor,
            tabs: logic.state.videoSourceFormat!.video!
                .map((e) => Tab(text: e!.name!))
                .toList(),
            isScrollable: true,
            controller: logic.state.tabController,
          ),
        ),
      ),
      body: Container(
        color: commBgColor,
        child: TabBarView(
          controller: logic.state.tabController,
          children: createTabConList(),
        ),
      ),
    );
  }

  /// 剧集 tabCon
  List<Widget> createTabConList() {
    List<Widget> list = [];
    logic.state.videoSourceFormat!.video!.asMap().keys.forEach((int tabIdx) {
      List<Widget> playListBtns = logic.state.videoSourceFormat!.video![tabIdx]!.list!
          .asMap()
          .keys
          .map((int activeIdx) {
        return Padding(
          padding: EdgeInsets.all(5),
          child: Obx(() => ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(
                  tabIdx == logic.curTabIdx.value && activeIdx == logic.curActiveIdx.value
                      ? Colors.red
                      : Colors.blue),
            ),
            onPressed: () async {
              debugPrint("tabIdx = $tabIdx, activeIdx = $activeIdx");
              logic.onChangeVideo(tabIdx, activeIdx);
              String nextVideoUrl =
              logic.state.videoSourceFormat!.video![logic.curTabIdx.value]!.list![logic.curActiveIdx.value]!.url!;
              // 切换播放源
              await logic.state.player.stop();
              await logic.state.player.reset();
              debugPrint("nextVideoUrl = $nextVideoUrl");
              logic.state.player.setDataSource(nextVideoUrl, autoPlay: true);
            },
            child: Text(
              logic.state.videoSourceFormat!.video![tabIdx]!.list![activeIdx]!.name!,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )),
        );
      }).toList();
      //
      list.add(
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Wrap(
              direction: Axis.horizontal,
              children: playListBtns,
            ),
          ),
        ),
      );
    });
    return list;
  }
}
