import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/ui/ranking/components/ranking_size_config.dart';
import 'package:ble_project/ui/ranking/ranking/logic.dart';
import 'package:ble_project/util/time_util.dart';
import 'package:ble_project/widget/keepalive_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetBuilder, Get, GetNavigation;
import 'package:shimmer/shimmer.dart';

Widget rankingShowView() {
  return keepAliveWrapper(
    AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: GetBuilder<RankingLogic>(
        id: "rankingShow",
        init: RankingLogic(),
        builder: (logic) {
          int _count = logic.state.showVodList.length;
          return _count > 0
              ? ListView.builder(
                  cacheExtent: 500,
                  scrollDirection: Axis.vertical,
                  itemCount: logic.state.showVodList.length,
                  itemBuilder: (BuildContext context, int index) => _ItemCell(
                    index: index,
                    data: logic.state.showVodList[index],
                    onTap: () => {
                      Get.toNamed(
                        RouterConfigs.detail,
                        arguments: {
                          'movieId': logic.state.showVodList[index].vodID,
                        },
                      ),
                    },
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  cacheExtent: 500,
                  separatorBuilder: (_, __) => _SeparatorItem(),
                  itemCount: _count + 1,
                  itemBuilder: (_, index) {
                    return const Offstage(
                      offstage: false,
                      child: const _ShimmerList(),
                    );
                  },
                );
        },
      ),
    ),
  );
}

class _SeparatorItem extends StatelessWidget {
  const _SeparatorItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: const EdgeInsets.only(left: 130),
      child: const Divider(),
    );
  }
}

class _ShimmerCell extends StatelessWidget {
  const _ShimmerCell({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final _rightPanelWidth = width - RankingSizeConfig.ShimmerListRightPadding;
    final _color = const Color(0xFFFFFFFF);
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      height: 200,
      child: Row(
        children: [
          Container(
            height: 200,
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _color,
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: _rightPanelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 30,
                  width: _rightPanelWidth - 50,
                  color: _color,
                ),
                const SizedBox(height: 5),
                Container(
                  height: 15,
                  width: _rightPanelWidth - 50,
                  color: _color,
                ),
                const SizedBox(height: 5),
                Container(
                  height: 15,
                  width: _rightPanelWidth - 50,
                  color: _color,
                ),
                const SizedBox(height: 15),
                Container(height: 18, color: _color),
                const SizedBox(height: 5),
                Container(height: 18, width: 350, color: _color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: shimmerColorDark,
      highlightColor: shimmerColorLight,
      child: Column(
        ///默认4个骨架
        children: [
          const SizedBox(height: 20),
          Column(
            children: List.filled(
              4,
              0,
            ).map((e) => const _ShimmerCell()).toList(),
          ),
        ],
      ),
    );
  }
}

class _ItemCell extends StatelessWidget {
  final int index;
  final VodInfo data;
  final Function() onTap;
  const _ItemCell({
    required this.index,
    required this.data,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final _rightPanelWidth = width - RankingSizeConfig.ListItemRightPadding;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        constraints: const BoxConstraints(minHeight: 150),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  height: 150,
                  width: 110,
                  decoration: BoxDecoration(
                    color: shimmerColorLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: Radius.zero,
                      bottomLeft: const Radius.circular(10.0),
                      bottomRight: const Radius.circular(35.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appThemeData.brightness == Brightness.light
                            ? const Color(0xFF8E8E8E)
                            : const Color(0x00000000),
                        offset: const Offset(0, 15),
                        blurRadius: 10,
                        spreadRadius: -10,
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(data.vodPic),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: _rightPanelWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.vodName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                          children: <InlineSpan>[
                            TextSpan(text: 'detail.detail_overall_rating'.tr()),
                            TextSpan(
                              text: "${data.vodHits}",
                              style: TextStyle(
                                color: const Color(0xFF109E9E),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                          children: <InlineSpan>[
                            TextSpan(text: 'detail.detail_year_area'.tr()),
                            TextSpan(
                              text: data.vodYear,
                              style: const TextStyle(
                                color: const Color(0xFF109E9E),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(text: " ${data.vodArea}"),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'detail.detail_actor'.tr(
                          namedArgs: {'vodActor': '${data.vodActor}'},
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'detail.detail_publish_time'.tr(
                          namedArgs: {
                            'vodTime':
                                '${TimeUtil.timeStampToTimeStr(data.vodTime)}',
                          },
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Visibility(
                // visible: index == 0 || index == 1 || index == 2,
                child: Container(
                  alignment: Alignment.center,
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.red
                        : index == 1
                        ? Colors.orange
                        : index == 2
                        ? Colors.amber
                        : Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: appThemeData.brightness == Brightness.light
                            ? const Color(0xFF8E8E8E)
                            : const Color(0x00000000),
                        offset: const Offset(0, 10),
                        blurRadius: 10,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: appThemeData.primaryColorLight,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Muli",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
