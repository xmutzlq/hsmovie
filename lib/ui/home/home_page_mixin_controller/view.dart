import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/home/home_result.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/category/category.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:ble_project/widget/list/movie_list.dart';
import 'package:ble_project/widget/slideshow/slideshow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetView, StateExt, Get, Inst, GetNavigation;
import 'logic.dart';

class HomePageMixin extends GetView<HomePageMixinControllerLogic> {

  final logic = Get.find<HomePageMixinControllerLogic>();

  HomePageMixin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
            (homeResult) => _homePageMixinControllerPage(homeResult!),
        onLoading: screenLoadingState(),
        onError: (error) => screenErrorState(error),
        onEmpty: screenEmptyStateFull()
    );
  }

  Widget _homePageMixinControllerPage(HomeResult homeResult) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: commBgColor,
      appBar: appBarHome,
      body: RefreshIndicator(
        onRefresh: () async {
          var homeData = await MovieRepository().fetchHome();
          logic.parserDataWithChange(homeData);
          return Future.value(true);
        },
        child: Container(
          child: ScrollConfiguration(
            behavior: MyScrollBehavior(),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SlideShowView(),
                  const Padding(padding: const EdgeInsets.only(top: 10)),
                  MovieCategory(),
                  const Padding(padding: const EdgeInsets.only(top: 10)),
                  _buildMovieList('home.categories_latest_movies'.tr(), homeResult.homeEntity.newestMovie),
                  const Padding(padding: const EdgeInsets.only(top: 10)),
                  _buildMovieList('home.categories_latest_tv_series'.tr(), homeResult.homeEntity.newestSeries),
                  const Padding(padding: const EdgeInsets.only(top: 10)),
                  _buildMovieList('home.categories_latest_variety_shows'.tr(), homeResult.homeEntity.newestVarietyShow),
                  const Padding(padding: const EdgeInsets.only(top: 10)),
                  _buildMovieList('home.categories_latest_anime'.tr(), homeResult.homeEntity.newestAnimation),
                ]
              )
            )
          )
        )
      )
    );
  }

  _buildMovieList(String title, var vodList) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(title, style: TextStyle(
                    color: appThemeData.primaryColor,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Muli")
                  )
                ),
                InkWell(
                  onTap: () => {
                    if(logic.filterTypes == null) {
                      ToastUtil.showToast("查不到分类列表，请刷新界面")
                    } else {
                      if('home.categories_latest_movies'.tr() == title) {
                        if(logic.filterTypes!.movieFilter != null && logic.filterTypes!.movieFilter!.length > 0) {
                          Get.toNamed(RouterConfigs.more, arguments: {
                            'title':'home.categories_latest_movies'.tr(),
                            'vodTypeId' : logic.filterTypes!.movieFilter![0].id})
                        } else {
                          ToastUtil.showToast("查不到电影分类，请刷新界面")
                        }
                      } else if('home.categories_latest_tv_series'.tr() == title) {
                        if(logic.filterTypes!.tvFilter != null && logic.filterTypes!.tvFilter!.length > 0) {
                          Get.toNamed(RouterConfigs.more, arguments: {
                            'title':'home.categories_latest_tv_series'.tr(),
                            'vodTypeId' : logic.filterTypes!.tvFilter![0].id})
                        } else {
                          ToastUtil.showToast("查不到连续剧分类，请刷新界面")
                        }
                      } else if('home.categories_latest_variety_shows'.tr() == title) {
                        Get.toNamed(RouterConfigs.more, arguments: {
                          'title':'home.categories_latest_variety_shows'.tr(),
                          'vodTypeId' : 3})
                      } else if('home.categories_latest_anime'.tr() == title) {
                        if(logic.filterTypes!.cartoonFilter != null && logic.filterTypes!.cartoonFilter!.length > 0) {
                          Get.toNamed(RouterConfigs.more, arguments: {
                            'title':'home.categories_latest_anime'.tr(),
                            'vodTypeId' : logic.filterTypes!.cartoonFilter![0].id})
                        } else {
                          ToastUtil.showToast("查不到动漫分类，请刷新界面")
                        }
                      }
                    }
                  },
                  child: Icon(Icons.arrow_forward, color: appThemeData.primaryColor)
                )
              ],
            ),
          ),
          MovieListView(items: vodList, onItemInteraction: (movieId) {
            Get.toNamed(RouterConfigs.detail, arguments: {'movieId' : movieId});
          })
        ]
      )
    );
  }
}

