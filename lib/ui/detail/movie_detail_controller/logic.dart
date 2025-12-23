import 'package:add_to_cart_animation/add_to_cart_icon.dart';
import 'package:ble_project/model/detail/movie_detail_entity.dart';
import 'package:ble_project/model/movie_enum.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/model/film_box_info.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/state.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:ble_project/ui/user/personal/model/movie_info.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/fix_vertical_card_pager.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

class MovieDetailControllerLogic extends GetxController with StateMixin<MovieDetailEntity> {
  static const String BOX_NAME_FILM_BOX = "box_film_box";
  static const String BOX_KEY_FILM_BOX = "key_film_box";
  static const int MAX_BOX_SIZE = 5;
  final MovieDetailControllerState detailState = MovieDetailControllerState();
  final personalLogic = Get.find<PersonalLogic>();

  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  final GlobalKey<FixVerticalCardPagerState> slideKey = GlobalKey<FixVerticalCardPagerState>();
  Function(GlobalKey)? runAddToCartAnimation;
  late List<MovieInfo> boxMovies;

  void changeExpanded(bool isExpanded) {
    detailState.isExpanded = isExpanded;
    update();
  }

  Future<void> runAddToCart(GlobalKey key) async {
    if(runAddToCartAnimation != null) {
      await runAddToCartAnimation!(key);
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    debugPrint("MovieDetailControllerLogic_onReady");
    var map = Get.arguments;
    int movieId = map['movieId'];
    getMovieDetailRemoteData(movieId.toString());
    super.onReady();
  }

  void getMovieDetailRemoteData(String movieId) async {
    change(null, status: RxStatus.loading());
    var movieDetailData = await MovieRepository().fetchMovieDetail(movieId);
    if(movieDetailData.ok) {
      MovieDetailEntity entity = MovieDetailEntity.fromJson(movieDetailData.data);
      // logD('${JsonEncoder.withIndent('  ').convert(entity)}');
      detailState.entity = entity;
      checkFilm(FilmType.containsType((entity.vod.typeID ?? -1).toString()));
      // 增加浏览记录
      saveBrowsingRecord();
      change(entity, status: RxStatus.success());
    } else {
      change(null, status: RxStatus.error(movieDetailData.error?.message));
    }
  }

  void checkFilm(bool isFilm) {
    detailState.isFilm.value = isFilm;
  }

  Future<int> getFilmsInBoxSize() async {
    List<MovieInfo> films = await getFilmsInBox();
    debugPrint('filmsInBoxSize : ${films.length}');
    return films.length;
  }

  /// 获取影视盒子里的影视
  Future<List<MovieInfo>> getFilmsInBox() async {
    var filmBox = await Hive.openBox<FilmBoxInfo>(BOX_NAME_FILM_BOX);
    FilmBoxInfo filmBoxInfo = filmBox.get(BOX_KEY_FILM_BOX) ?? FilmBoxInfo(filmBoxRecord: []);
    boxMovies = filmBoxInfo.filmBoxRecord ?? [];
    debugPrint('getFilmsInBox_length : ${boxMovies.length}');
    return filmBoxInfo.filmBoxRecord ?? [];
  }

  /// 添加到影视盒子
  Future<bool> saveFilm2Box(String? movieId) async {
    bool isSuccess = false;
    if(movieId == null) {
      ToastUtil.showToast("movieId不能为空");
      return false;
    }
    MovieDetailEntity? entity = detailState.entity;
    if(entity == null) {
      ToastUtil.showToast("数据异常");
      return false;
    }
    var filmBox = await Hive.openBox<FilmBoxInfo>(BOX_NAME_FILM_BOX);
    FilmBoxInfo filmBoxInfo = filmBox.get(BOX_KEY_FILM_BOX) ?? FilmBoxInfo(filmBoxRecord: []);
    List<MovieInfo> movies = filmBoxInfo.filmBoxRecord ?? [];
    bool hasInside = false;
    if(movies.length > 0) {
      if(MAX_BOX_SIZE <= movies.length) {
        ToastUtil.showToast("盒子最多只能添加5个电影");
        return false;
      }

      int foundIndex = movies.indexWhere((item) => item.movieId == movieId);
      hasInside = foundIndex != -1;
    }
    // 不存在则添加进去
    if(!hasInside) {
      movies.add(MovieInfo(movieId: movieId,
          movieName: entity.vod.vodName,
          movieImg: entity.vod.vodPic,
          movieType: (entity.vod.typeID ?? -1).toString()));
      filmBoxInfo.copyWith(filmBoxRecord: movies);
      await filmBox.put(BOX_KEY_FILM_BOX, filmBoxInfo);
      isSuccess = true;
    } else {
      ToastUtil.showToast("该影片已存在盒子中");
    }
    return isSuccess;
  }

  /// 清空影视盒子
  Future<bool> clearFilmsInBox() async {
    bool isSuccess = false;
    try {
      var filmBox = await Hive.openBox<FilmBoxInfo>(BOX_NAME_FILM_BOX);
      await filmBox.clear();
      // FilmBoxInfo filmBoxInfo = filmBox.get(BOX_KEY_FILM_BOX) ?? FilmBoxInfo(filmBoxRecord: []);
      // filmBoxInfo.copyWith(filmBoxRecord: []);
      // await filmBox.put(BOX_KEY_FILM_BOX, filmBoxInfo);
      boxMovies = [];
      isSuccess = true;
    } catch(e) {
      isSuccess = false;
    }
    return isSuccess;
  }

  /// 删除影视盒子中的某个Film
  Future<bool> deleteAFilmInBox(int index) async {
    bool isSuccess = false;
    try {
      var filmBox = await Hive.openBox<FilmBoxInfo>(BOX_NAME_FILM_BOX);
      FilmBoxInfo filmBoxInfo = filmBox.get(BOX_KEY_FILM_BOX) ?? FilmBoxInfo(filmBoxRecord: []);
      MovieInfo? info = filmBoxInfo.filmBoxRecord?.removeAt(index);
      if(info != null) {
        await filmBox.put(BOX_KEY_FILM_BOX, filmBoxInfo);
        boxMovies = filmBoxInfo.filmBoxRecord!;
        debugPrint('getDeletedFilmsInBox_length : ${boxMovies.length}');
        isSuccess = true;
      } else {
        isSuccess = false;
      }
    } catch(e) {
      isSuccess = false;
    }
    return isSuccess;
  }

  void updateFilmBox() {
    update(['film_box_update']);
  }

  /// 添加浏览记录
  void saveBrowsingRecord() {
    MovieDetailEntity? entity = detailState.entity;
    if(entity != null) {
      personalLogic.saveBrowsingRecord(entity.vod.vodID.toString(), entity.vod.vodPic, entity.vod.vodName,
          (entity.vod.typeID ?? -1).toString());
    }
  }

  /// 添加收藏
  Future<void> saveFavourite() async {
    MovieDetailEntity? entity = detailState.entity;
    if(entity != null) {
      await personalLogic.saveFavouriteRecord(
          entity.vod.vodID.toString(),
          entity.vod.vodPic,
          entity.vod.vodName,
          (entity.vod.typeID ?? -1).toString());
    }
  }

  @override
  void onClose() {
    debugPrint("MovieDetailControllerLogic_onClose");
    super.onClose();
  }

}
