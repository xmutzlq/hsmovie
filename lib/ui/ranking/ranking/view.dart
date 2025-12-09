import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/ranking/components/ranking_tab_bar_top.dart';
import 'package:ble_project/ui/ranking/components/ranking_tab_bar_view_cartoons.dart';
import 'package:ble_project/ui/ranking/components/ranking_tab_bar_view_movie.dart';
import 'package:ble_project/ui/ranking/components/ranking_tab_bar_view_show.dart';
import 'package:ble_project/ui/ranking/components/ranking_tab_bar_view_tv.dart';
import 'package:ble_project/ui/ranking/ranking/state.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/sliverappbar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import 'logic.dart';

class RankingPage extends StatelessWidget {
  final logic = Get.find<RankingLogic>();
  final state = Get.find<RankingLogic>().state;

  RankingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: Scaffold(
        backgroundColor: commBgColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: appThemeData.brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: SafeArea(
            child: NestedScrollView(
              // controller: logic.scrollController,
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, bool) {
                return [
                  SliverPersistentHeader(
                    floating: true,
                    delegate: SliverAppBarDelegate(
                      minHeight: 60,
                      maxHeight: 60,
                      child: _FilterBar(
                        onFilterPress: () => {ToastUtil.showToast("即将开放")}
                      )
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                      minHeight: 50,
                      maxHeight: 50,
                      child: rankingTabBarView(),
                    ),
                  )
                ];
              },
              body: TabBarView(
                controller: logic.tabController,
                children: [
                  rankingMovieView(),
                  rankingTvView(),
                  rankingShowView(),
                  rankingCartoonView()
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCell extends StatelessWidget {
  final _horizontalPadding = 15;
  final double _cardHeight = 200;
  final double _borderRadius = 20;
  final double _imageWidth = 120;
  final double _rightPanelPadding = 10;

  const _ShimmerCell({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final _rightPanelWidth = width - _imageWidth - _horizontalPadding * 2 - _rightPanelPadding * 2;
    return Container(
      height: _cardHeight,
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_borderRadius),
              bottomLeft: Radius.circular(_borderRadius),
              bottomRight: Radius.circular(_imageWidth / 2)),
          child: Container (
            width: _imageWidth,
            height: _cardHeight,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(_rightPanelPadding),
          child: SizedBox(
            width: _rightPanelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 13,
                  color: const Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 7.5),
                Container(
                  width: 40,
                  height: 7.5,
                  color: const Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 2.5),
                Container(
                  width: 60,
                  height: 7.5,
                  color: const Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 100,
                  height: 7.5,
                  color: const Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 10,
                  color: const Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 10,
                  color: const Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 125,
                  height: 10,
                  color: const Color(0xFFFFFFFF),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  final bool isBusy;
  const _ShimmerList({required this.isBusy});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child:  isBusy? Shimmer.fromColors(
        baseColor: appThemeData.primaryColorDark,
        highlightColor: appThemeData.primaryColorLight,
        child: Container(
          margin: const EdgeInsets.only(top: 5, bottom: 15, left: 15, right: 15),
          child: Column(
            children: <Widget>[
              const _ShimmerCell(),
              const SizedBox(height: 15),
              const _ShimmerCell(),
              const SizedBox(height: 15),
              const _ShimmerCell(),
            ],
          ),
        ),
      )
          : const SizedBox(),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final logic = Get.find<RankingLogic>();
  final Function() onFilterPress;

  _FilterBar({required this.onFilterPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: commBgColor,
      child: Stack(children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
                color: appThemeData.brightness == Brightness.light
                    ? const Color(0xFFEFEFEF)
                    : const Color(0xFF505050)),
            borderRadius: BorderRadius.circular(10),
            color: Colors.black12
          ),
          child: Row(
            children: [
              _TapPanel(),
              Expanded(child: const SizedBox()),
              GestureDetector(
                onTap: onFilterPress,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: appThemeData.primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    size: 15,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              )
            ],
          ),
        ),
        _Loading(),
      ]),
    );
  }
}

class _TapPanel extends StatelessWidget {
  final logic = Get.find<RankingLogic>();
  final TextStyle _selectedStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 17);
  final TextStyle _unSelectedStyle = TextStyle(color: const Color(0xFF9E9E9E), fontSize: 15);

  _TapPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        Obx(() => Row(children: [
          _TapCell(
            onTap: () => logic.updateRanking(RankingState.RANKING_TYPE_WEEK),
            title: '周版',
            textStyle: RankingState.RANKING_TYPE_WEEK == logic.state.currentRankingIndex.value ? _selectedStyle : _unSelectedStyle,
          ),
          _TapCell(
            onTap: () => logic.updateRanking(RankingState.RANKING_TYPE_MONTH),
            title: '月版',
            textStyle: RankingState.RANKING_TYPE_MONTH == logic.state.currentRankingIndex.value ? _selectedStyle : _unSelectedStyle,
          ),
          _TapCell(
            onTap: () => logic.updateRanking(RankingState.RANKING_TYPE_ALL),
            title: '总版',
            textStyle: RankingState.RANKING_TYPE_ALL == logic.state.currentRankingIndex.value ? _selectedStyle : _unSelectedStyle,
          )
        ])),
    SlideTransition(
      position: logic.positionAnimation,
      child: Container(
        padding: const EdgeInsets.only(top: 32),
        width: 50,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appThemeData.brightness == Brightness.light
                ? const Color(0xFF334455)
                : const Color(0xFFFFFFFF),
          ),
        ),
      ),
    ),
    ]);
  }
}

class _TapCell extends StatelessWidget {
  final String title;
  final TextStyle textStyle;
  final Function() onTap;
  const _TapCell({required this.title, required this.onTap, required this.textStyle});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 50,
        child: Center(
          child: Text(
            title,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  final logic = Get.find<RankingLogic>();
  @override
  Widget build(BuildContext context) {
    final _brightness = appThemeData.brightness == Brightness.light;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Obx(() => logic.state.loadingBusy.value ? Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 10),
        height: 60,
        child: SizedBox(
          height: 1,
          child: LinearProgressIndicator(
            backgroundColor: _brightness
                ? const Color(0xFFEFEFEF)
                : const Color(0xFF505050),
            valueColor: AlwaysStoppedAnimation(
              _brightness
                  ? const Color(0xFF334455)
                  : const Color(0xFFFFFFFF),
            ),
          ),
        ),
      )
          : const SizedBox()),
    );
  }
}
