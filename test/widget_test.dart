import 'package:ble_project/base/skin/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buffered playback slider reports the selected position', (
    tester,
  ) async {
    double? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 48,
            child: BufferedSlider(
              value: 20,
              cacheValue: 60,
              min: 0,
              max: 100,
              onChanged: (value) => selected = value,
              onChangeEnd: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    await tester.drag(find.byType(BufferedSlider), const Offset(120, 0));
    await tester.pump();
    expect(selected, isNotNull);
    expect(selected, inInclusiveRange(0, 100));
  });
}
