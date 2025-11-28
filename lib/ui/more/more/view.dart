import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/util/time_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'logic.dart';

class MorePage extends StatelessWidget {
  final logic = Get.find<MoreLogic>();

  MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: commBgColor,
      appBar: AppBar(
        title: GestureDetector(
          onDoubleTap: () => logic.listScrollTop(),
          child: Obx(
            () => Text(
              logic.state.title.value,
              style: TextStyle(color: appThemeData.primaryColor, fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: appThemeData.primaryColor, //change your color here
        ),
        elevation: 0.0,
        backgroundColor: commBgColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: GetBuilder<MoreLogic>(
        builder: (logic) {
          return logic.state.moreList.length > 0
              ? EasyRefresh(
                  scrollController: logic.controller,
                  header: const MaterialHeader(),
                  footer: const MaterialFooter(),
                  onRefresh: () async {
                    var moreData = await logic.refreshMoreData(true);
                    logic.updateResultForRefresh(moreData, true);
                  },
                  onLoad: () async {
                    var moreData = await logic.refreshMoreData(false);
                    logic.updateResultForRefresh(moreData, false);
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _ItemCell(
                            data: logic.state.moreList[index],
                            onTap: () => {
                              Get.toNamed(
                                RouterConfigs.detail,
                                arguments: {
                                  'movieId': logic.state.moreList[index].vodID,
                                },
                              ),
                            },
                          );
                        }, childCount: logic.state.moreList.length),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  cacheExtent: 500,
                  separatorBuilder: (_, __) => _SeparatorItem(),
                  itemCount: 1,
                  itemBuilder: (_, index) {
                    return const Offstage(
                      offstage: false,
                      child: const _ShimmerList(),
                    );
                  },
                );
        },
      ),
    );
  }
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
  final VodInfo data;
  final Function() onTap;

  const _ItemCell({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
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
                        const TextSpan(text: "年份地区："),
                        TextSpan(
                          text: data.vodYear,
                          style: TextStyle(
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
                    "主演：${data.vodActor}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "时间：${TimeUtil.timeStampToTimeStr(data.vodTime)}",
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
      ),
    );
  }
}
