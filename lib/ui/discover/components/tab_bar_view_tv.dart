import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/discovery/discovery_result.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:ble_project/ui/discover/discovery/logic.dart';
import 'package:ble_project/util/time_util.dart';
import 'package:ble_project/widget/keepalive_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:shimmer/shimmer.dart';

Widget tvView() {

  final logic = Get.find<DiscoveryLogic>();

  int groupComparator(String value1, String value2) {
    String compareStr2 = value2.substring(0, value2.indexOf("-"));
    String compareStr1 = value1.substring(0, value1.indexOf("-"));
    return int.parse(compareStr2).compareTo(int.parse(compareStr1));
  }

  return keepAliveWrapper(AnimatedSwitcher(
    key: Key("tvView"),
    duration: Duration(milliseconds: 600),
    child: GetBuilder<DiscoveryLogic>(builder: (logic) {
      int _count = logic.state.discoveryTvGroups?.length ?? 0;
      return _count > 0 ? RefreshIndicator(
          child: SizeCacheWidget(
          estimateCount: 112,
          child: GroupedListView<DiscoveryGroupInfo, String>(
            cacheExtent: 500,
            elements: logic.state.discoveryTvGroups!,
            groupBy: (element) => element.name.toString(),
            order: GroupedListOrder.DESC,
            groupComparator: (value1, value2) => groupComparator(value1, value2),
            floatingHeader: true,
            useStickyGroupSeparators: true,
            groupSeparatorBuilder: (String value) => Container(
              height: 35,
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value.substring(value.indexOf("-") + 1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            itemBuilder: (_, element) => FrameSeparateWidget(
              placeHolder: _ShimmerCell(),
              child: _ItemCell(
                data: element.vodInfo,
                onTap: () => Get.toNamed(RouterConfigs.detail, arguments: {'movieId' : element.vodInfo.vodID}),
              ),
            ),
          )),
          onRefresh: () async {
            logic.getTvDataWithRefresh();
            String type = "2";
            var movieData = await MovieRepository().fetchMovies(type);
            logic.responseRemoteData(type, movieData);
            //结束刷新
            return Future.value(true);
          })
          : ListView.separated(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20),
        cacheExtent: 500,
        separatorBuilder: (_, __) => _SeparatorItem(),
        itemCount: _count + 1,
        itemBuilder: (_, index) {
          return Offstage(
            offstage: logic.state.tvPage == logic.state.tvTotalPages && _count > 0,
            child: const _ShimmerList(),
          );
        },
      );
    })
  ));
}

class _SeparatorItem extends StatelessWidget {
  const _SeparatorItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 130), child: Divider());
  }
}

class _ShimmerCell extends StatelessWidget {
  const _ShimmerCell({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    final _rightPanelWidth = width - 200;
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
                color: _color),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: _rightPanelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(height: 30, width: _rightPanelWidth - 50, color: _color),
                SizedBox(height: 5),
                Container(height: 15, width: _rightPanelWidth - 50, color: _color),
                SizedBox(height: 5),
                Container(height: 15, width: _rightPanelWidth - 50, color: _color),
                SizedBox(height: 15),
                Container(height: 18, color: _color),
                SizedBox(height: 5),
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
            SizedBox(height: 20),
            Column(
              children: List.filled(4, 0).map((e) => const _ShimmerCell()).toList(),
            )
          ]
      ),
    );
  }
}

class _ItemCell extends StatelessWidget {
  final VodInfo data;
  final Function() onTap;
  const _ItemCell({required this.data, required this.onTap});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    final _rightPanelWidth = width - 170;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        constraints: const BoxConstraints(minHeight: 150),
        child: Row(
          children: [
            Container(
              height: 150,
              width: 110,
              decoration: BoxDecoration(
                color: shimmerColorLight,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(35.0)
                ),
                boxShadow: [
                  BoxShadow(
                      color: appThemeData.brightness == Brightness.light
                          ? const Color(0xFF8E8E8E)
                          : const Color(0x00000000),
                      offset: Offset(0, 15),
                      blurRadius: 10,
                      spreadRadius: -10)
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(data.vodPic,),
                ),
              ),
            ),
            SizedBox(width: 20),
            SizedBox(
              width: _rightPanelWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.vodName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "年份地区：${data.vodYear + " " + data.vodArea}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  Text(
                    "演员：${data.vodActor}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "时间：${TimeUtil.timeStampToTimeStr(data.vodTime)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}