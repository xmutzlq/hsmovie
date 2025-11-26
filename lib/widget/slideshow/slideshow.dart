import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlideShowView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<HomePageMixinControllerLogic>(
      id: 'week_hot',
      init: HomePageMixinControllerLogic(), // use it only first time on each controller
      builder: (logic) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: width / 2,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            itemCount: logic.weekHot.length,
            itemBuilder: (context, index, realIdx) {
              return InkWell(onTap: () => Get.toNamed(RouterConfigs.detail, arguments: {'movieId': logic.weekHot[index].vodID}),
                child: Container(
                    width: width,
                    child: _buildItem(logic.weekHot[index].vodPic, logic.weekHot[index].vodName)),
              );
            }
          ),
        );
      },
    );
  }

  _buildItem(String imagePath, String? title) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 10.0,
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
              height: constraints.biggest.height,
              width: constraints.biggest.width,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              width: constraints.biggest.width,
              height: constraints.biggest.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    const Color(0x00000000),
                    const Color(0x00000000),
                    const Color(0x22000000),
                    const Color(0x66000000),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  title?.toUpperCase() ?? "--",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Muli'),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
