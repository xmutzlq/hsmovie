import 'dart:io';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void showToast(String msg) {
    if (Platform.isWindows) {
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
    if (Platform.isWindows) {
      SmartDialog.dismiss(status: SmartStatus.toast);
      return;
    }
    Fluttertoast.cancel();
  }
}
