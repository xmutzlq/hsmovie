import 'package:ble_project/ui/player/player_controller/logic.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 懒加载的TabPage
class LazyTabPage extends StatelessWidget {
  final controller = Get.find<PlayerControllerLogic>();

  final int index;
  final List<Widget> playListBtns;

  LazyTabPage({super.key, required this.index, required this.playListBtns});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: _makePlayList(),
      ),
    );
  }

  Widget _makePlayList() {
    return Obx(() => (index == controller.curTabPageIdx.value)
        ? Wrap(direction: Axis.horizontal, children: playListBtns)
        : screenLoadingStateForTabView());
  }
}
