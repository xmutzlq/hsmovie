import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void showToast(String msg) {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      SmartDialog.showToast(msg);
      return;
    }
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  static void cancelAllToast() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      SmartDialog.dismiss(status: SmartStatus.toast);
      return;
    }
    Fluttertoast.cancel();
  }
}
