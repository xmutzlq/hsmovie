import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget buildWithWindowsRealMediaQuery(
  BuildContext context,
  WidgetBuilder builder,
) {
  if (defaultTargetPlatform != TargetPlatform.windows) {
    return builder(context);
  }
  return MediaQuery.fromView(
    view: View.of(context),
    child: Builder(builder: builder),
  );
}
