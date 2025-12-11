import 'dart:math';
import 'dart:ui';

import 'package:ble_project/base/log/app_log.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:ble_project/ui/user/personal/model/person_info.dart';
import 'package:ble_project/ui/user/personal/state.dart';
import 'package:ble_project/util/keyboard_util.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:random_avatar/random_avatar.dart';

import 'model/avatar_state.dart';
import 'model/movie_info.dart';

class PersonalLogic extends GetxController with StateMixin<List<String>> {
  static const String BOX_NAME_PERSONAL = "box_personal";
  static const String BOX_KEY_PERSONAL = "key_personal";
  static const int MAX_RECORD_SIZE = 10;

  final homeLogic = Get.find<HomePageMixinControllerLogic>();

  final Random _random = Random();
  final PersonalState personState = PersonalState();
  /// 当前保存的头像index
  int currentSelectedAvatarIndex = -1;
  /// 当前保存昵称
  String? nicknameStr = '';

  @override
  Future<void> onInit() async {
    super.onInit();
    _setPersonInfo();
    _getViewingRecord();
    _getBrowsingRecord();
    _getFavourite();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color get randomColor => Color.fromARGB(
    255,
    _random.nextInt(256),
    _random.nextInt(256),
    _random.nextInt(256),
  );

  Future<void> _setPersonInfo() async {
    personState.nickName.value = await _getNicknameFromDB() ?? '昵称';
    personState.avatarSVGStr.value = await _getAvatarSVGFromDB() ?? '';
  }

  Future<String?> _getNicknameFromDB() async {
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    return personBox.get(BOX_KEY_PERSONAL)?.nickName ?? "";
  }

  Future<String?> _getAvatarSVGFromDB() async {
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    return personBox.get(BOX_KEY_PERSONAL)?.avatarSVG ?? "";
  }

  Future<bool> saveNicknameAndAvatarSvgToDB() async {
    if(nicknameStr == null || nicknameStr!.isEmpty) {
      ToastUtil.showToast('请选输入昵称');
      return false;
    }
    if(nicknameStr!.length < 4) {
      ToastUtil.showToast('昵称至少4位');
      return false;
    }
    if(currentSelectedAvatarIndex == -1) {
      ToastUtil.showToast('请选择一个头像');
      return false;
    }

    String avatarSVGStr = personState.avatarItemStatus[currentSelectedAvatarIndex]?.avatar ?? '';
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo personInfo = personBox.get(BOX_KEY_PERSONAL)
        ?? PersonInfo(nickName: '', avatarSVG: '', favourite: [], viewingRecord: [], browsingRecord: []);
    PersonInfo updatedPerson = personInfo.copyWith(
        nickName: nicknameStr, avatarSVG: avatarSVGStr);
    await personBox.put(BOX_KEY_PERSONAL, updatedPerson);
    // 需要触发更新“我的”页面中的头像和昵称
    _setPersonInfo();
    return true;
  }

  Future<void> getRandomAvatars() async {
    currentSelectedAvatarIndex = -1;
    change(null, status: RxStatus.loading());
    // await Future.delayed(Duration(seconds: 5)); // 模拟网络请求
    try {
      List<String> fakeData = await List.generate(20, (index) => _getARandomAvatar());
      for (int i = 0; i < fakeData.length; i++) {
        personState.avatarItemStatus[i] = AvatarItemState(isSelected: false, avatar: fakeData[i]);
      }
      change(fakeData, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error('Avatar加载失败: $e'));
    }
  }

  String _getARandomAvatar() {
    return RandomAvatarString(DateTime.now().toIso8601String());
  }

  void singleAvatarSelected(int index) {
    if(Get.context != null) KeyBoardUtil.hideKeyboard(Get.context!);
    if(index == -1) return;
    if(currentSelectedAvatarIndex != -1) {
      _toggleSelection(currentSelectedAvatarIndex);
    }
    _toggleSelection(index);
    currentSelectedAvatarIndex = index;
  }

  /// 只更新特定项的状态
  void _toggleSelection(int index) {
    if(personState.avatarItemStatus.isEmpty || index == -1) return;
    final current = personState.avatarItemStatus[index]!;
    personState.avatarItemStatus[index] = current.copyWith(
      isSelected: !current.isSelected
    );
    // 使用 updateId 只更新特定项
    update(['item_$index']);
  }

  void updateNickNameValue(String? nickname) {
    this.nicknameStr = nickname;
  }

  /// 保存观看记录到DB
  void saveViewingRecord(String movieId, String movieImg, String movieName,
      String movieType) async {
    logD('movieId : $movieId, movieImg : $movieImg, movieName : $movieName');
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo personInfo = personBox.get(BOX_KEY_PERSONAL)
        ?? PersonInfo(nickName: '', avatarSVG: '', favourite: [], viewingRecord: [], browsingRecord: []);
    List<MovieInfo> viewingMovies = personInfo.viewingRecord ?? [];
    // 查看是否是相同的
    bool hasSame = false;
    for(MovieInfo info in viewingMovies) {
      if(info.movieId == movieId) {
        hasSame = true;
        return;
      }
    }
    if(hasSame) return;
    MovieInfo movieInfo = MovieInfo(movieId: movieId, movieName: movieName, movieImg: movieImg,
        movieType: movieType);
    viewingMovies.insert(0, movieInfo);
    // 暂时不同去掉超过项
    // if (viewingMovies.length > MAX_RECORD_SIZE) {
    //   viewingMovies.removeLast();
    // }
    PersonInfo updatedPerson = personInfo.copyWith(
        nickName: personInfo.nickName,
        avatarSVG: personInfo.avatarSVG,
        favourite: personInfo.favourite,
        viewingRecord: viewingMovies,
        browsingRecord: personInfo.browsingRecord);
    await personBox.put(BOX_KEY_PERSONAL, updatedPerson);
    _updateViewingRecord(updatedPerson);
  }

  /// 保存收藏DB
  void saveFavouriteRecord(String movieId, String movieImg, String movieName,
      String movieType) async {
    logD('movieId : $movieId, movieImg : $movieImg, movieName : $movieName');
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo personInfo = personBox.get(BOX_KEY_PERSONAL)
        ?? PersonInfo(nickName: '', avatarSVG: '', favourite: [], viewingRecord: [], browsingRecord: []);
    List<MovieInfo> favouriteMovies = personInfo.favourite ?? [];
    // 查看是否是相同的
    bool hasSame = false;
    for(MovieInfo info in favouriteMovies) {
      if(info.movieId == movieId) {
        hasSame = true;
        return;
      }
    }
    if(hasSame) return;
    MovieInfo movieInfo = MovieInfo(movieId: movieId, movieName: movieName, movieImg: movieImg,
        movieType: movieType);
    favouriteMovies.insert(0, movieInfo);
    // 暂时不同去掉超过项
    // if (viewingMovies.length > MAX_RECORD_SIZE) {
    //   viewingMovies.removeLast();
    // }
    PersonInfo updatedPerson = personInfo.copyWith(
        nickName: personInfo.nickName,
        avatarSVG: personInfo.avatarSVG,
        favourite: favouriteMovies,
        viewingRecord: personInfo.viewingRecord,
        browsingRecord: personInfo.browsingRecord);
    await personBox.put(BOX_KEY_PERSONAL, updatedPerson);
    _updateFavourite(updatedPerson);
  }

  /// 保存浏览记录到DB
  void saveBrowsingRecord(String movieId, String movieImg, String movieName,
      String movieType) async {
    logD('movieId : $movieId, movieImg : $movieImg, movieName : $movieName');
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo personInfo = personBox.get(BOX_KEY_PERSONAL)
        ?? PersonInfo(nickName: '', avatarSVG: '', favourite: [], viewingRecord: [], browsingRecord: []);
    List<MovieInfo> browsingMovies = personInfo.browsingRecord ?? [];
    // 查看是否是相同的
    bool hasSame = false;
    for(MovieInfo info in browsingMovies) {
      if(info.movieId == movieId) {
        hasSame = true;
        return;
      }
    }
    if(hasSame) return;
    MovieInfo movieInfo = MovieInfo(movieId: movieId, movieName: movieName, movieImg: movieImg,
        movieType: movieType);
    browsingMovies.insert(0, movieInfo);
    // 暂时不同去掉超过项
    // if (viewingMovies.length > MAX_RECORD_SIZE) {
    //   viewingMovies.removeLast();
    // }
    PersonInfo updatedPerson = personInfo.copyWith(
        nickName: personInfo.nickName,
        avatarSVG: personInfo.avatarSVG,
        favourite: personInfo.favourite,
        viewingRecord: personInfo.viewingRecord,
        browsingRecord: browsingMovies);
    await personBox.put(BOX_KEY_PERSONAL, updatedPerson);
    _updateBrowsingRecord(updatedPerson);
  }

  /// 获取观看记录列表
  Future<void> _getViewingRecord() async {
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo? personInfo = personBox.get(BOX_KEY_PERSONAL);
    _updateViewingRecord(personInfo);
  }

  /// 获取浏览记录列表
  Future<void> _getBrowsingRecord() async {
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo? personInfo = personBox.get(BOX_KEY_PERSONAL);
    _updateBrowsingRecord(personInfo);
  }

  /// 获取收藏列表
  Future<void> _getFavourite() async {
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo? personInfo = personBox.get(BOX_KEY_PERSONAL);
    _updateFavourite(personInfo);
  }

  /// 更新观看记录
  void _updateViewingRecord(PersonInfo? personInfo) {
    if(personInfo != null) {
      personState.viewingRecordSize.value = (personInfo.viewingRecord?.length ?? 0).toString();
      List<MovieInfo>? topTen = personInfo.viewingRecord?.take(MAX_RECORD_SIZE).toList();
      if(topTen != null && topTen.isNotEmpty) {
        personState.viewingRecord.value = topTen;
      }
    }
  }

  /// 更新浏览记录
  void _updateBrowsingRecord(PersonInfo? personInfo) {
    if(personInfo != null) {
      personState.browsingRecordSize.value = (personInfo.browsingRecord?.length ?? 0).toString();
      List<MovieInfo>? topTen = personInfo.browsingRecord?.take(MAX_RECORD_SIZE).toList();
      if(topTen != null && topTen.isNotEmpty) {
        personState.browsingRecord.value = topTen;
      }
    }
  }

  /// 更新收藏
  void _updateFavourite(PersonInfo? personInfo) {
    if(personInfo != null) {
      personState.favouriteSize.value = (personInfo.favourite?.length ?? 0).toString();
      List<MovieInfo>? topTen = personInfo.favourite?.take(MAX_RECORD_SIZE).toList();
      if(topTen != null && topTen.isNotEmpty) {
        personState.favourite.value = topTen;
      }
    }
  }

  /// 只更新特定项的状态
  Future<void> analysisMovieTypes() async {
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo? personInfo = personBox.get(BOX_KEY_PERSONAL);
    List<MovieInfo>? viewingRecord = personInfo?.viewingRecord;
    viewingRecord?.forEach((element) {
      // 电影
      homeLogic.filterTypes?.movieFilter?.forEach((el) {
        if(element.movieType == el.id) {
          personState.statistics.movieFilter?.add(element);
          return;
        };
      });
      // 电视剧
      homeLogic.filterTypes?.tvFilter?.forEach((el) {
        if(element.movieType == el.id) {
          personState.statistics.tvFilter?.add(element);
          return;
        };
      });
      // 综艺
      homeLogic.filterTypes?.showFilter?.forEach((el) {
        if(element.movieType == el.id) {
          personState.statistics.showFilter?.add(element);
          return;
        };
      });
      // 动漫
      homeLogic.filterTypes?.cartoonFilter?.forEach((el) {
        if(element.movieType == el.id) {
          personState.statistics.cartoonFilter?.add(element);
          return;
        };
      });
    });
    // 使用 updateId 只更新特定项
    update(['movie_types_statistics']);
  }
}