import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/logic.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:ble_project/widget/fix_vertical_card_pager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:logger_easier/logger_easier.dart';

void showFilmInBoxDialog() {
  SmartDialog.show(
    builder: (context) => Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GetBuilder<MovieDetailControllerLogic>(
                    id: 'film_box_update',
                    builder: (controller) {
                      return controller.boxMovies.length > 0
                        ? IconButton(
                          icon: const Icon(Icons.cleaning_services_outlined,),
                          onPressed: () async {
                            SmartDialog.show(
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('温馨提示'),
                                  content: const Text('确定要清空播放盒子吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        SmartDialog.dismiss();
                                      },
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // 清空播放盒子内容
                                        bool isSuccess = await controller.clearFilmsInBox();
                                        if (isSuccess) {
                                          ToastUtil.showToast("清除成功");
                                          await controller.cartKey.currentState!.runCartAnimation('0');
                                          controller.updateFilmBox();
                                        } else {
                                          ToastUtil.showToast("清除失败");
                                        }
                                        SmartDialog.dismiss();
                                      },
                                      child: const Text('确认'),
                                    )
                                  ]
                                );
                              }
                            );
                          }
                        )
                        : SizedBox();
                    },
                  ),
                  const Text(
                    '电影播放盒子',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.0,
                    )
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      SmartDialog.dismiss();
                    }
                  )
                ]
              ),
              const SizedBox(height: 15),
              Text(
                '您添加的电影将会被全部播放，\n按添加的顺序自动播放盒子中的电影',
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: GetBuilder<MovieDetailControllerLogic>(
                  id: 'film_box_update',
                  builder: (controller) {
                    return Container(
                      child: controller.boxMovies.length > 0
                          ? FixVerticalCardPager(
                        key: controller.slideKey,
                        titles: controller.boxMovies.map((e) {
                          return e.movieName?.toUpperCase() ?? '';
                        }).toList(),
                        images: controller.boxMovies.mapIndexed((index, e) =>
                            Column(children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: shimmerColorLight,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: const Radius.circular(20.0),
                                      topRight: const Radius.circular(20.0),
                                      bottomLeft: const Radius.circular(20.0),
                                      bottomRight: const Radius.circular(20.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: appThemeData.brightness == Brightness.light
                                            ? const Color(0xFF8E8E8E,)
                                            : const Color(0x00000000,),
                                        offset: const Offset(0, 15,),
                                        blurRadius: 10,
                                        spreadRadius: -10,
                                      )
                                    ],
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                        e.movieImg ?? '',
                                      )
                                    )
                                  )
                                )
                              ),
                              SizedBox(height: 6),
                              Text(
                                (e.movieName?.length ?? 0) > 16
                                    ? e.movieName?.substring(0, 16) ?? ''
                                    : e.movieName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                )
                              )
                            ]
                          )
                        ).toList(),
                        textStyle: TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.transparent,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 4.0,
                        ),
                        initialPage: controller.boxMovies.length - 1,
                        onSelectedItem: (index) {
                          debugPrint('onSelectedItem : $index');
                          if(!controller.slideKey.currentState!.isShowSlide.value) {
                            SmartDialog.show(
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: const Text('温馨提示'),
                                      content: Text("确定要从《${controller.boxMovies[index].movieName}》开始播放吗？"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            SmartDialog.dismiss();
                                          },
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () async {

                                            SmartDialog.dismiss();
                                          },
                                          child: const Text('确认'),
                                        )
                                      ]
                                  );
                                }
                            );
                          }
                        },
                        onDeleteItem: (index) async {
                          debugPrint('onDeleteItem : $index');
                          // 删除播放盒子一条
                          bool isSuccess = await controller.deleteAFilmInBox(index);
                          if (isSuccess) {
                            ToastUtil.showToast("删除成功");
                            try {
                              int filmSize = await controller.getFilmsInBoxSize();
                              await controller.cartKey.currentState!.runCartAnimation(filmSize.toString());
                            } catch(e) {
                              debugPrint('获取盒子中的影视数量异常: $e');
                            }
                            controller.updateFilmBox();
                            controller.slideKey.currentState!.updatePageView();
                          } else {
                            ToastUtil.showToast("删除失败");
                          }
                        }
                      )
                          : screenEmptyStateFull(),
                    );
                  }
                )
              )
            ]
          )
        )
      )
    )
  );
}
