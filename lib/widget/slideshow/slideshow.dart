import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:ble_project/util/desktop_platform.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlideShowView extends StatefulWidget {
  const SlideShowView({super.key});

  @override
  State<SlideShowView> createState() => _SlideShowViewState();
}

class _SlideShowViewState extends State<SlideShowView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final isDesktop = isDesktopLayoutPlatform;
    final bannerHeight = isDesktop
        ? (size.height * 0.38).clamp(240.0, 420.0)
        : width / 2;
    return GetBuilder<HomePageMixinControllerLogic>(
      id: 'week_hot',
      init:
          HomePageMixinControllerLogic(), // use it only first time on each controller
      builder: (logic) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: bannerHeight,
              aspectRatio: 16 / 9,
              viewportFraction: isDesktop ? 0.68 : 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: isDesktop ? 0.18 : 0.3,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
            ),
            itemCount: logic.weekHot.length,
            itemBuilder: (context, index, realIdx) {
              return InkWell(
                onTap: () => Get.toNamed(
                  RouterConfigs.detail,
                  arguments: {'movieId': logic.weekHot[index].vodID},
                ),
                child: _buildItem(
                  logic.weekHot[index].vodPic,
                  logic.weekHot[index].vodName,
                  isDesktop: isDesktop,
                  targetSize: Size(
                    width * (isDesktop ? 0.68 : 0.8),
                    bannerHeight,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItem(
    String imagePath,
    String? title, {
    required bool isDesktop,
    required Size targetSize,
  }) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 10.0,
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (isDesktop) ...[
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Transform.scale(
                scale: 1.08,
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            const ColoredBox(color: Color(0x52000000)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: targetSize.width * 0.04,
                vertical: 12,
              ),
              child: CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                fadeInDuration: const Duration(milliseconds: 180),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ] else
            CachedNetworkImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          Container(
            alignment: Alignment.bottomLeft,
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
                  fontFamily: 'Muli',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
