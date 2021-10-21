import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:flutter/material.dart';

class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget(this.child);

  @override
  State<StatefulWidget> createState() => KeepAliveState();
}

class KeepAliveState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScrollConfiguration(behavior: MyScrollBehavior(), child: widget.child);
  }
}

Widget keepAliveWrapper(Widget child) {
  return KeepAliveWidget(child);
}