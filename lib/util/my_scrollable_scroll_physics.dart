import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class MyScrollableScrollPhysics extends ScrollPhysics {
  bool _acceptUserOffset = true;

  /// Creates scroll physics that does not let the user scroll.
  MyScrollableScrollPhysics({ ScrollPhysics? parent}) : super(parent: parent);

  @override
  MyScrollableScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyScrollableScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => _acceptUserOffset;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {

    final double overscrollPastStart = math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd = math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast = math.max(overscrollPastStart, overscrollPastEnd);

    debugPrint("overscrollPastStart = " + overscrollPastStart.toString()
        + ", overscrollPastEnd = " + overscrollPastEnd.toString() + ", overscrollPast = " + overscrollPast.toString());

    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  bool get allowImplicitScrolling => false;
}