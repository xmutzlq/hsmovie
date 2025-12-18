import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/logic.dart';
import 'package:ble_project/ui/user/personal/model/movie_info.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

void showFilmInBoxDialog(List<MovieInfo> movies, Function clear) {
  SmartDialog.show(
    builder: (context) => Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GetBuilder<MovieDetailControllerLogic>(
                      id: 'film_box_update', // 关键：为每个item指定唯一ID
                      builder: (controller) {
                    return movies.length > 0
                        ? IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        SmartDialog.show(
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('温馨提示'),
                              content: Text('确定要清空播放盒子吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    SmartDialog.dismiss();
                                  },
                                  child: Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    clear();
                                    SmartDialog.dismiss();
                                  },
                                  child: Text('确认'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ): SizedBox();
                  }),
                  Text(
                    '电影播放盒子',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      SmartDialog.dismiss();
                    },
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                '在播放完您当前观看的电影后，\n自动播放盒子中的电影',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: Container(
                  child: movies.length > 0
                      ? VerticalCardPager(
                          titles: movies
                              .map((e) => e.movieName?.toUpperCase() ?? '')
                              .toList(),
                          images: movies
                              .map(
                                (e) => Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: shimmerColorLight,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: const Radius.circular(
                                              20.0,
                                            ),
                                            topRight: const Radius.circular(
                                              20.0,
                                            ),
                                            bottomLeft: const Radius.circular(
                                              20.0,
                                            ),
                                            bottomRight: const Radius.circular(
                                              20.0,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  appThemeData.brightness ==
                                                      Brightness.light
                                                  ? const Color(0xFF8E8E8E)
                                                  : const Color(0x00000000),
                                              offset: const Offset(0, 15),
                                              blurRadius: 10,
                                              spreadRadius: -10,
                                            ),
                                          ],
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                              e.movieImg ?? '',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      (e.movieName?.length ?? 0) > 8
                                          ? e.movieName?.substring(0, 8) ?? ''
                                          : e.movieName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                          textStyle: TextStyle(
                            fontSize: 60.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.transparent,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 4.0,
                          ),
                          initialPage: movies.length - 1,
                          onPageChanged: (page) {},
                          onSelectedItem: (index) {},
                        )
                      : screenEmptyStateFull(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
