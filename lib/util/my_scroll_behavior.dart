import 'dart:ui';

import 'package:flutter/material.dart';

///
/// Custom scroll behavior of list view
/// Remove overflow color when scroll list view
///
class MyScrollBehavior extends ScrollBehavior {
  const MyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
