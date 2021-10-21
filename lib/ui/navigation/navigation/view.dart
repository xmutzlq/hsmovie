import 'package:ble_project/base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class NavigationPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationLogic>(
      builder: (logic) {
        return WillPopScope(
          onWillPop: () async => logic.exitApp(),
          child: Scaffold(
            ///采用IndexedStack方式防止界面刷新
              body: IndexedStack(
                index: logic.state.bottomBarIndex.value,
                children: logic.state.bodyPageList,
              ),
              ///底部导航条
              bottomNavigationBar: BottomNavigationBar(
                /// 当前菜单下标
                currentIndex: logic.state.bottomBarIndex.value,
                /// 点击事件,获取当前点击的标签下标
                onTap: (int index) => logic.changeBottomBarIndex(index),
                iconSize: 30.0,
                fixedColor: primaryDarkColor,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
                  BottomNavigationBarItem(icon: Icon(Icons.movie), label: "发现"),
                  BottomNavigationBarItem(icon: Icon(Icons.sort), label: "排行")
                ],
              )
          )
        );
      },
    );
  }
}
