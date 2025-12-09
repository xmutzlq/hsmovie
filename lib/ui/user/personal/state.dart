import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/avatar_state.dart';

class PersonalState {
  RxString nickName = '昵称'.obs;
  RxString avatarSVGStr = ''.obs;
  var avatarItemStatus = <int, AvatarItemState>{}.obs;

  late ScrollController scrollController;

  PersonalState() {
    ///Initialize variables
    scrollController = ScrollController();
  }
}