import 'package:animated_flip_widget/animated_flip_widget.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/vod_class.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/ui/user/components/movie_chart.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:ble_project/widget/list/movie_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zo_animated_border/zo_animated_border.dart';

import 'logic.dart';

class PersonalPage extends StatelessWidget {
  static const double cardElevation = 0.5;
  static const Color cardBgColor = Colors.white60;
  final PersonalLogic personalController = Get.put(PersonalLogic());

  PersonalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: appThemeData.brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildRecordContent(),
                  _buildViewingRecord(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 头部(头像，昵称编辑)
  Widget _buildHeader() {
    return Card(
      color: cardBgColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: cardElevation,
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            padding: const EdgeInsets.all(15),
            child: Row(
              spacing: 15,
              children: <Widget>[
                _buildAvatar(),
                Expanded(child: _buildNickname()),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouterConfigs.person_edit);
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: const Icon(Icons.edit_note, size: 30),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnknownAvatar() {
    return InkWell(
      onTap: () {
        Get.toNamed(RouterConfigs.person_edit);
      },
      borderRadius: const BorderRadius.all(Radius.circular(75)),
      child: ZoBreathingBorder(
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(75),
        colors: [Colors.blue, Colors.purple, Colors.red, Colors.orange],
        animationDuration: const Duration(seconds: 4),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(75),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person_pin, size: 30),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(
      () => personalController.personState.avatarSVGStr.value.isNotEmpty
          ? SvgPicture.string(
              '${personalController.personState.avatarSVGStr}',
              width: 60,
              height: 60,
            )
          : _buildUnknownAvatar(),
    );
  }

  Widget _buildNickname() {
    return Obx(
      () => Text(
        '${personalController.personState.nickName}',
        style: Theme.of(
          Get.context!,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 收藏、观看记录、浏览记录
  Widget _buildRecordContent() {
    return AnimatedFlipWidget(
      front: Card(
        color: cardBgColor,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: cardElevation,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10,),
              child: Row(
                spacing: 15,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () { personalController.personState.flipController.flip(); },
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: _buildFavouriteItem('收藏'),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        personalController.personState.flipController.flip();
                        await personalController.analysisMovieTypes();
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: _buildViewingRecordItem('观看记录'),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () { personalController.personState.flipController.flip(); },
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: _buildBrowsingRecordItem('浏览记录'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      back: _buildChart(),
      clickable: false,
      flipDuration: const Duration(milliseconds: 600),
      flipDirection: personalController.personState.flipDirection,
      controller: personalController.personState.flipController,
    );
  }

  Widget _buildChart() {
    return Stack( // 1. 使用Stack作为底层布局
      children: [
        Card(
          color: cardBgColor,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: cardElevation,
          margin: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: buildViewingRecordChart(),
        ),
        // 2. 使用Positioned将Icon精确定位在右上角
        Positioned(
          top: 6.0,
          right: 15.0,
          child: IconButton(
            icon: const Icon(Icons.swap_vert_outlined), // 使用更多选项图标
            onPressed: () {
              // 处理图标点击事件，例如弹出菜单
              personalController.personState.flipController.flip();
            },
          ),
        )
      ],
    );
  }

  Widget _buildViewingRecordItem(String recordName) {
    return Column(
      children: [
        Text(recordName, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Obx(() => Text(
          personalController.personState.viewingRecordSize.value,
          style: const TextStyle(
            color: const Color(0xFF109E9E),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        )),
      ],
    );
  }

  Widget _buildBrowsingRecordItem(String recordName) {
    return Column(
      children: [
        Text(recordName, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Obx(() => Text(
          personalController.personState.browsingRecordSize.value,
          style: const TextStyle(
            color: const Color(0xFF109E9E),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        )),
      ],
    );
  }

  Widget _buildFavouriteItem(String recordName) {
    return Column(
      children: [
        Text(recordName, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Obx(() => Text(
          personalController.personState.favouriteSize.value,
          style: const TextStyle(
            color: const Color(0xFF109E9E),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        )),
      ],
    );
  }

  Widget _buildViewingRecord(BuildContext context) {
    bool hasViewingRecord = personalController.personState.viewingRecord.isNotEmpty;
    debugPrint('hasViewingRecord : $hasViewingRecord');
    return Obx(
      () => personalController.personState.viewingRecord.isNotEmpty
          ? Card(
              color: cardBgColor,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: cardElevation,
              margin: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15,),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    padding: const EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            const Icon(Icons.history, size: 25),
                            SizedBox(width: 3),
                            Text(
                              '观看记录',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        _buildMovieList(context),
                      ],
                    ),
                  );
                },
              ),
            )
          : SizedBox(),
    );
  }

  Widget _buildMovieList(BuildContext context) {
    List<VodInfo> vodInfos = [];
    var viewingList = personalController.personState.viewingRecord;
    viewingList.forEach((item) {
      VodInfo info = VodInfo(
        int.parse(item.movieId ?? '0'),
        item.movieName ?? '',
        item.movieImg ?? '',
        '', '', '', 0, '', '', 0, 0, VodClass(0, ''),
      );
      vodInfos.add(info);
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: MovieListView(
        items: vodInfos,
        onItemInteraction: (movieId) {
          Get.toNamed(RouterConfigs.detail, arguments: {'movieId': movieId});
        },
        leftPaddingControl: -10,
      )
    );
  }
}
