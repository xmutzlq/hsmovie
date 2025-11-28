import 'package:ble_project/util/class_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

mixin AutoWidgetsFlutterBinding on WidgetsFlutterBinding {
  bool _appLifecycleStateLocked = true;

  @override
  void initInstances() {
    super.initInstances();
    debugPrint("${ClazzUtil.getClassName(this)} -> initInstances");
    _instance = this;
    changeAppLifecycleState(AppLifecycleState.resumed);
  }

  static AutoWidgetsFlutterBinding? get instance => _instance;
  static AutoWidgetsFlutterBinding? _instance;

  @override
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    if (_appLifecycleStateLocked) {
      return;
    }
    debugPrint("${ClazzUtil.getClassName(this)} -> handleAppLifecycleStateChanged ${state.toString()}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    super.handleAppLifecycleStateChanged(state);
  }

  void changeAppLifecycleState(AppLifecycleState state) {
    if (SchedulerBinding.instance.lifecycleState == state) {
      return;
    }
    _appLifecycleStateLocked = false;
    handleAppLifecycleStateChanged(state);
    _appLifecycleStateLocked = true;
  }
}