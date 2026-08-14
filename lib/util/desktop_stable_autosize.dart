import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DesktopStableAutosize extends StatefulWidget {
  const DesktopStableAutosize({super.key, required this.child});

  final Widget child;

  @override
  State<DesktopStableAutosize> createState() => _DesktopStableAutosizeState();
}

class _DesktopStableAutosizeState extends State<DesktopStableAutosize>
    with WidgetsBindingObserver {
  static const double _standardExtent = 360;

  MediaQueryData? _data;
  _ViewMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateData();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final changed = _updateData();
    if (changed) setState(() {});
  }

  bool _updateData() {
    final view = View.of(context);
    final metrics = _ViewMetrics.fromView(view);
    if (_metrics == metrics && _data != null) return false;

    final raw = MediaQueryData.fromView(view);
    final portrait = raw.size.height > raw.size.width;
    final scale = portrait
        ? raw.size.width / _standardExtent
        : raw.size.height / _standardExtent;
    final safeScale = scale > 0 ? scale : 1.0;
    final adaptedSize = portrait
        ? Size(_standardExtent, raw.size.height / safeScale)
        : Size(raw.size.width / safeScale, _standardExtent);

    _metrics = metrics;
    _data = raw.copyWith(
      size: adaptedSize,
      devicePixelRatio: safeScale,
      viewInsets: _adaptInsets(raw.viewInsets, safeScale),
      padding: _adaptInsets(raw.padding, safeScale),
      viewPadding: _adaptInsets(raw.viewPadding, safeScale),
    );
    return true;
  }

  EdgeInsets _adaptInsets(EdgeInsets value, double scale) =>
      EdgeInsets.fromLTRB(
        value.left,
        value.top / scale,
        value.right,
        value.bottom / scale,
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateData();
    return MediaQuery(data: _data!, child: widget.child);
  }
}

class _ViewMetrics {
  const _ViewMetrics(this.physicalSize, this.devicePixelRatio);

  factory _ViewMetrics.fromView(ui.FlutterView view) =>
      _ViewMetrics(view.physicalSize, view.devicePixelRatio);

  final Size physicalSize;
  final double devicePixelRatio;

  @override
  bool operator ==(Object other) =>
      other is _ViewMetrics &&
      other.physicalSize == physicalSize &&
      other.devicePixelRatio == devicePixelRatio;

  @override
  int get hashCode => Object.hash(physicalSize, devicePixelRatio);
}
