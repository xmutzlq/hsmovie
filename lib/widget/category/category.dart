import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MovieCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<HomePageMixinControllerLogic>(
      id: 'categories',
      init: HomePageMixinControllerLogic(), // use it only first time on each controller
      builder: (logic) {
        return Container(
          height: width / 5,
          margin: const EdgeInsets.all(10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: logic.categories.length > 10 ? 10 : logic.categories.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(
                logic.categories[index].cateImg,
                logic.categories[index].cateName,
                width / 3);
            },
          ),
        );
      }
    );
  }

  _buildItem(String imagePath, String cate, double itemHeight) {
    final logic = Get.find<HomePageMixinControllerLogic>();
    return GestureDetector(
      onTap: () => {
        if("本周热播" == cate) {
          Get.toNamed(RouterConfigs.simple_list, arguments: {'simpleListTitle' : "本周热播" , 'simpleListArgument' : logic.weekHot})
        } else {
          if(logic.filterTypes == null) {
            ToastUtil.showToast("查不到分类列表，请刷新界面")
          } else {
            if("最新电影" == cate) {
              if(logic.filterTypes!.movieFilter != null && logic.filterTypes!.movieFilter!.length > 0) {
                Get.toNamed(RouterConfigs.more, arguments: {'title':'电影', 'vodTypeId' : logic.filterTypes!.movieFilter![0].id})
              } else {
                ToastUtil.showToast("查不到电影分类，请刷新界面")
              }
            } else if("最新连续剧" == cate) {
              if(logic.filterTypes!.tvFilter != null && logic.filterTypes!.tvFilter!.length > 0) {
                Get.toNamed(RouterConfigs.more, arguments: {'title':'连续剧', 'vodTypeId' : logic.filterTypes!.tvFilter![0].id})
              } else {
                ToastUtil.showToast("查不到连续剧分类，请刷新界面")
              }
            } else if("最新综艺" == cate) {
              Get.toNamed(RouterConfigs.more, arguments: {'title':'综艺', 'vodTypeId' : 3})
            } else if("最新动漫" == cate) {
              if(logic.filterTypes!.cartoonFilter != null && logic.filterTypes!.cartoonFilter!.length > 0) {
                Get.toNamed(RouterConfigs.more, arguments: {'title':'动漫', 'vodTypeId' : logic.filterTypes!.cartoonFilter![0].id})
              } else {
                ToastUtil.showToast("查不到动漫分类，请刷新界面")
              }
            }
          }
        }
      },
      child: Container(
        width: itemHeight * 4 / 3,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 10.0,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(10.0))),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: <Widget>[
                  Image(image: CachedNetworkImageProvider(imagePath),
                    fit: BoxFit.cover,
                    height: constraints.biggest.height,
                    width: constraints.biggest.width,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: constraints.biggest.width,
                    height: constraints.biggest.height,
                    decoration: const BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          const Color(0x99ff0000),
                          const Color(0x66ff0000),
                          const Color(0x66ff0000),
                          const Color(0x99ff0000),
                        ],
                      ),),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(cate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Muli'
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
        ),
      ),
    );
  }
}