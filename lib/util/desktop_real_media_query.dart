import 'package:ble_project/util/desktop_platform.dart';
import 'package:flutter/material.dart';

Widget buildWithDesktopRealMediaQuery(
  BuildContext context,
  WidgetBuilder builder,
) {
  if (!isDesktopLayoutPlatform) {
    return builder(context);
  }
  return MediaQuery.fromView(
    view: View.of(context),
    child: Builder(builder: builder),
  );
}
