import 'dart:math';
import 'dart:ui';

import 'package:ble_project/base/log/app_log.dart';
import 'package:ble_project/ui/user/personal/model/person_info.dart';
import 'package:ble_project/ui/user/personal/state.dart';
import 'package:ble_project/util/keyboard_util.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:random_avatar/random_avatar.dart';

import 'model/avatar_state.dart';

class PersonalLogic extends GetxController with StateMixin<List<String>> {
  static const String BOX_NAME_PERSONAL = "box_personal";
  static const String BOX_KEY_PERSONAL = "key_personal";
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

  Future<void> saveNicknameAndAvatarSvgToDB() async {
    if(nicknameStr == null || nicknameStr!.isEmpty) {
      ToastUtil.showToast('请选输入昵称');
      return;
    }
    if(nicknameStr!.length < 4) {
      ToastUtil.showToast('昵称至少4位');
      return;
    }
    if(currentSelectedAvatarIndex == -1) {
      ToastUtil.showToast('请选择一个头像');
      return;
    }

    String avatarSVGStr = personState.avatarItemStatus[currentSelectedAvatarIndex]?.avatar ?? '';
    var personBox = await Hive.openBox<PersonInfo>(BOX_NAME_PERSONAL);
    PersonInfo personInfo = personBox.get(BOX_KEY_PERSONAL)
        ?? PersonInfo(nickName: '', avatarSVG: '', favourite: []);
    PersonInfo updatedPerson = personInfo.copyWith(
        nickName: nicknameStr, avatarSVG: avatarSVGStr);
    await personBox.put(BOX_KEY_PERSONAL, updatedPerson);
    // 需要触发更新“我的”页面中的头像和昵称
    _setPersonInfo();
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
}