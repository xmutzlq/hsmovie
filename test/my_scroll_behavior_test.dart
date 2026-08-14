import 'dart:ui';

import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desktop pointer devices can drag scrollable content', () {
    final dragDevices = const MyScrollBehavior().dragDevices;

    expect(dragDevices, contains(PointerDeviceKind.mouse));
    expect(dragDevices, contains(PointerDeviceKind.trackpad));
    expect(dragDevices, contains(PointerDeviceKind.touch));
  });
}
