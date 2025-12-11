import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/detail/movie_detail_entity.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:ble_project/util/class_util.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:ble_project/widget/list/guess_like_list.dart';
import 'package:ble_project/widget/list/recommend_list.dart';
import 'package:ble_project/widget/scrollview_background.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autosize_screen_pro/flutter_autosize_screen_pro.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import 'logic.dart';

class MovieDetailControllerPage extends GetView<MovieDetailControllerLogic> {

  final logic = Get.find<MovieDetailControllerLogic>();
  final homeLogic = Get.find<HomePageMixinControllerLogic>();

  MovieDetailControllerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
            (movieDetailResult) => _buildDetailContent(movieDetailResult!),
        onLoading: screenLoadingState(),
        onError: (error) => screenErrorState(error),
        onEmpty: screenEmptyStateFull()
    );
  }

  Widget _buildDetailContent(MovieDetailEntity entity) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildContent(entity),
          Positioned( //Place it at the top, and not use the entire screen
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              title: const Text(''),
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.white, //change your color here
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              //No more green
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white, // Here
                  ),
                  onPressed: () {
                    ToastUtil.showToast("即将开放");
                  },
                ),
              ], systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),),
        ],
      ),
    );
  }

  Widget _buildContent(MovieDetailEntity entity) {
    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: SingleChildScrollView(
        controller: logic.detailState.scrollController,
        child: Container(
          color: commBgColor,
          child: Column(
            children: <Widget>[
              _buildBackdrop(entity.vod.vodPic),
              const Padding(padding: const EdgeInsets.only(top: 10),),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildMovieName(entity.vod.vodName),
                    const Padding(padding: EdgeInsets.only(top: 10),),
                    _buildGenres([entity.vod.vodRemarks]),
                    const Padding(padding: EdgeInsets.only(top: 10),),
                    _buildRating(entity.vod.vodScore!.toDouble(), 5),
                    const Padding(padding: EdgeInsets.only(top: 10),),
                    _buildMovieInfo(entity.vod.vodYear, entity.vod.vodArea, entity.vod.vodClass.typeName,),
                    const Padding(padding: EdgeInsets.only(top: 10),),
                    _buildMovieDescription(entity.vod.vodContent),
                    const Padding(padding: EdgeInsets.only(top: 10),),
                    _buildYouLike(entity.rand),
                    const Padding(padding: EdgeInsets.only(top: 10),),
                    _buildRecommend(entity.relate)
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  _buildBackdrop(String backdrop) {
    return Container(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var width = constraints.biggest.width;
            return Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: _HeaderBackground(imgUrl: backdrop, scrollController: logic.detailState.scrollController),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(icon: const Icon(Icons.add_outlined,), onPressed: () {
                              ToastUtil.showToast("即将开放");
                            },),
                            Expanded(
                              child: Container(),
                            ),
                            IconButton(icon: const Icon(Icons.favorite_border,), onPressed: () {
                              logic.saveFavourite();
                            },),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: width / 2 - 27.5, ///
                  top: width,
                  child: FractionalTranslation(
                    translation: const Offset(0.0, -0.5),
                    child: FloatingActionButton(onPressed: () {
                      ///播放
                      if(logic.detailState.entity == null
                          || logic.detailState.entity!.vod.vodPlayServer == null
                          || logic.detailState.entity!.vod.vodPlayServer!.isEmpty) {
                        ToastUtil.showToast("暂无无播放资源");
                      } else {
                        // 加入观看记录
                        debugPrint('加入观看记录');
                        final PersonalLogic personalController = Get.put(PersonalLogic());
                        personalController.saveViewingRecord(
                            (logic.detailState.entity?.vod.vodID ?? 999).toString(),
                            logic.detailState.entity?.vod.vodPic ?? "",
                            logic.detailState.entity?.vod.vodName ?? "",
                            (logic.detailState.entity?.vod.typeID ?? -1).toString());

                        Navigator.of(context).pushNamed(RouterConfigs.player, arguments: {
                          'playServers' : logic.detailState.entity?.vod.vodPlayServer,
                          'playUrlInfo' : logic.detailState.entity?.vod.vodPlayUrls,
                          'videoTitle' : logic.detailState.entity?.vod.vodName});
                        // Get.toNamed(RouterConfigs.player, arguments: {
                        //       'playServers' : logic.detailState.entity?.vod.vodPlayServer,
                        //       'playUrlInfo' : logic.detailState.entity?.vod.vodPlayUrls,
                        //       'videoTitle' : logic.detailState.entity?.vod.vodName})
                      }
                    },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.play_arrow, color: Colors.red, size: 40,),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  _buildMovieName(String name) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      alignment: Alignment.center,
      child: Text(name,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.black87,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: "Muli"),
      ),
    );
  }

  _buildGenres(List<String> genres) {
    StringBuffer genresValue = StringBuffer();
    debugPrint("Genres size ${genres.length}");

    for (var item in genres) {
      if (genresValue.length != 0) {
        genresValue.write(", ");
      }
      genresValue.write(item);
    }

    return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        alignment: Alignment.center,
        child: Text(genresValue.toString(),
          style: const TextStyle(
              color: Colors.black45,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              fontFamily: "Muli"),)
    );
  }

  _buildRating(double voteAverage, int voteCount) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      alignment: Alignment.center,
      child: RatingBar.builder(
        initialRating: voteAverage,
        minRating: 0,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemSize: 20,
        itemCount: voteCount,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.red,
        ),
        onRatingUpdate: (rating) {
          debugPrint("rating = $rating");
        },
      ),
    );
  }

  _buildMovieInfo(String? year, String? productionCountry, String? type) {
    debugPrint("year = $year, country = $productionCountry, type = $type");
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          _buildMovieMoreInfoItem("年份", year ?? "--"),
          _buildMovieMoreInfoItem("地区", productionCountry ?? "--"),
          _buildMovieMoreInfoItem("类型", type ?? "--"),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  _buildMovieDescription(String? description) {
    debugPrint("${ClazzUtil.getClassName(this)} -> description : $description");
    final desc = description?.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .trim() ?? "";
    return GestureDetector(
      onTap: () => logic.changeExpanded(!logic.detailState.isExpanded),
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        alignment: Alignment.center,
        child: AnimatedCrossFade(
          firstChild: Text(
            desc,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.0,
                fontFamily: "Muli"),
          ),
          secondChild: Text(
            desc,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.0,
                fontFamily: "Muli"),),
          crossFadeState: logic.detailState.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ),
    );
  }

  /// 猜你喜欢
  _buildYouLike(List<VodInfo> items) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: const Text("猜你喜欢", style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Muli"),
                  ),
                ),
                // InkWell(
                //   onTap: () => {
                //     Get.toNamed(RouterConfigs.more, arguments: {'title':'猜你喜欢', 'vodTypeId' : logic.detailState.entity!.vod.typeID})
                //   },
                //   child: Icon(Icons.arrow_forward_outlined, color: Colors.black,),
                // )
              ],
            ),
          ),
          GuessLikeListView(items: items, onItemInteraction: (movieId) {
            debugPrint("handle_GuessLike_ite：$movieId");
            Navigator.of(Get.context!).pushReplacementNamed(RouterConfigs.detail, arguments: {'movieId' : movieId});
           },)
        ],
      ),
    );
  }

  /// 相关推荐
  _buildRecommend(List<VodInfo> items) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: const Text("相关推荐", style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Muli"),
                  ),
                ),
                // InkWell(
                //   onTap: () => {
                //     Get.toNamed(RouterConfigs.more, arguments: {'title':'相关推荐', 'vodTypeId' : logic.detailState.entity!.vod.typeID})
                //   },
                //   child: Icon(Icons.arrow_forward_outlined, color: Colors.black,),
                // )
              ],
            ),
          ),
          RecommendListView(items: items, onItemInteraction: (movieId) {
            debugPrint("handle_Recommend_item：$movieId");
            Navigator.of(Get.context!).pushReplacementNamed(RouterConfigs.detail, arguments: {'movieId' : movieId});
          },)
        ],
      ),
    );
  }

  _buildMovieMoreInfoItem(String title, String value) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.biggest.width > 100 ? 100 : double.infinity,
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: <Widget>[
                Text(title, style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Muli"),
                ),
                const Padding(padding: const EdgeInsets.only(top: 5),),
                Wrap(
                  children: <Widget>[
                    Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Muli"),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class _HeaderBackground extends StatefulWidget {
  final String imgUrl;
  final ScrollController scrollController;
  const _HeaderBackground({required this.imgUrl, required this.scrollController});
  @override
  _HeaderBackgroundState createState() => _HeaderBackgroundState();
}

class _HeaderBackgroundState extends State<_HeaderBackground> {
  static Size size = FlutterAutosizeScreenPro.getScreenSize();

  double _position = 0;
  double _height = 1150;
  void _imageScroll() {
    if (widget.scrollController.position.pixels <= _height) {
      _position = widget.scrollController.position.pixels;
    }
    setState(() {});
  }

  @override
  void initState() {
    debugPrint("HeaderBackground_initState");
    widget.scrollController.addListener(_imageScroll);
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("HeaderBackground_dispose");
    widget.scrollController.removeListener(_imageScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: size.width,
          child: CustomPaint(
            painter: MyShadowPainter(
              shadow: const Shadow(
                color: const Color(0xFF8E8E8E),
                offset: const Offset(0, -0.5),
                blurRadius: 10,
              ),
              clipper: MClipper()),
            child: ClipPath(
              clipper: MClipper(),
              child: Container(
                width: size.width,
                height: _height,
                child: CachedNetworkImage(
                  imageUrl: widget.imgUrl,
                  placeholder: (context, url) => new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                  fit: BoxFit.cover,)
              ),
            )
          ),
        ),
        ScrollViewBackGround(
          scrollController: widget.scrollController,
          height: 750,
          maxOpacity: 0.8,
        )
      ],
    );
  }
}

///裁剪
class MClipper extends CustomClipper<Path> {

  double deltaY;

  MClipper({this.deltaY = 0});

  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 40.0);

    var controlPoint = Offset(size.width / 4, size.height);
    var endpoint = Offset(size.width / 2, size.height - deltaY);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endpoint.dx, endpoint.dy);

    var controlPoint2 = Offset(size.width * 3 / 4, size.height);
    var endpoint2 = Offset(size.width, size.height - 40.0);

    path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy, endpoint2.dx, endpoint2.dy);

    path.lineTo(size.width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

///阴影
class MyShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  MyShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(Offset(0, 0));
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
