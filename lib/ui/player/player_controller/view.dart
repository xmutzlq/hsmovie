import 'package:ble_project/base/skin/media_kit_player_skin.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/global_config.dart';
import 'package:ble_project/ui/player/components/lazy_tab_page.dart';
import 'package:ble_project/util/desktop_platform.dart';
import 'package:ble_project/util/desktop_real_media_query.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'logic.dart';

class PlayerControllerPage extends StatelessWidget {
  PlayerControllerPage({super.key});

  final logic = Get.find<PlayerControllerLogic>();
  final state = Get.find<PlayerControllerLogic>().state;

  @override
  Widget build(BuildContext context) {
    return buildWithDesktopRealMediaQuery(context, (context) {
      final viewportSize = MediaQuery.sizeOf(context);
      final playerHeight = isDesktopLayoutPlatform
          ? (viewportSize.width * 9 / 16).clamp(
              260.0,
              viewportSize.height * 0.72,
            )
          : 260.0;
      return Material(
        child: Column(
          children: [
            SizedBox(
              height: playerHeight,
              child: Video(
                key: state.player.videoKey,
                controller: state.player.videoController,
                fit: BoxFit.cover,
                fill: Colors.black,
                pauseUponEnteringBackgroundMode: true,
                resumeUponEnteringForegroundMode: true,
                onEnterFullscreen: () async {
                  state.player.setFullScreen(true);
                  await defaultEnterNativeFullscreen();
                },
                onExitFullscreen: () async {
                  state.player.setFullScreen(false);
                  await defaultExitNativeFullscreen();
                },
                controls: (videoState) {
                  final viewportSize = isDesktopLayoutPlatform
                      ? MediaQueryData.fromView(
                          View.of(videoState.context),
                        ).size
                      : MediaQuery.sizeOf(videoState.context);
                  final size = state.player.value.fullScreen
                      ? viewportSize
                      : Size(viewportSize.width, playerHeight);
                  return Obx(
                    () => CustomMediaKitPanel(
                      player: state.player,
                      viewSize: size,
                      texturePos: Offset.zero & size,
                      pageContent: videoState.context,
                      playerTitle: logic.title.value,
                      onChangeVideo: logic.onChangeVideo,
                      curTabIdx: logic.curTabIdx.value,
                      curActiveIdx: logic.curActiveIdx.value,
                      showConfig: state.showConfigAbs,
                      videoFormat: state.videoSourceFormat,
                      tabController: state.tabController!,
                    ),
                  );
                },
              ),
            ),
            Expanded(child: _buildPlayDrawer()),
            if (!Global.isRelease)
              Container(
                color: Colors.white,
                child: Obx(
                  () => Text(
                    '当前TabIndex : ${logic.curTabIdx}, 当前PlayIndex : ${logic.curActiveIdx}',
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPlayDrawer() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: AppBar(
          titleSpacing: 0,
          backgroundColor: commBgColor,
          automaticallyImplyLeading: false,
          primary: false,
          elevation: 0,
          title: TabBar(
            indicatorColor: appThemeData.primaryColor,
            tabs: state.videoSourceFormat!.video!
                .map((source) => Tab(text: source!.name!))
                .toList(),
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            controller: state.tabController,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: state.tabController,
          children: _createTabContent(),
        ),
      ),
    );
  }

  List<Widget> _createTabContent() {
    final tabs = <Widget>[];
    for (final tabEntry in state.videoSourceFormat!.video!.asMap().entries) {
      final tabIndex = tabEntry.key;
      final source = tabEntry.value!;
      final buttons = <Widget>[];
      for (final episodeEntry in source.list!.asMap().entries) {
        final episodeIndex = episodeEntry.key;
        final episode = episodeEntry.value!;
        buttons.add(
          Padding(
            padding: const EdgeInsets.all(5),
            child: Obx(
              () => ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(
                    tabIndex == logic.curTabIdx.value &&
                            episodeIndex == logic.curActiveIdx.value
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
                onPressed: () async {
                  logic.onChangeVideo(tabIndex, episodeIndex);
                  await state.player.stop();
                  await state.player.reset();
                  await logic.playEpisode(episode.url!, episode.name ?? '');
                },
                child: Text(
                  episode.name!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      }
      tabs.add(
        buttons.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: screenEmptyStateForTabView(),
              )
            : LazyTabPage(index: tabIndex, playListBtns: buttons),
      );
    }
    return tabs;
  }
}
