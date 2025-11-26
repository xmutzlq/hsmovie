import 'dart:async';
import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void runAutoApp(Widget app) {
  WidgetsFlutterBinding.ensureInitialized();
  AutoWidgetsFlutterBinding.ensureInitialized()
    ..attachRootWidget(app)
    ..scheduleWarmUpFrame();
}

class AutoWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static WidgetsBinding ensureInitialized() {
    return WidgetsBinding.instance;
  }

  /// 因为修改了 devicePixelRatio ，得适配点击事件  GestureBinding
  @override
  void initInstances() {
    super.initInstances();
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  @override
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked)
      scheduleMicrotask(_flushPointerEventQueue);
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  void _flushPointerEventQueue() {
    assert(!locked);
    while (_pendingPointerEvents.isNotEmpty)
      _handlePointerEvent(_pendingPointerEvents.removeFirst());
  }

  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};

  void _handlePointerEvent(PointerEvent event) {
    assert(!locked);
    HitTestResult result;
    if (event is PointerDownEvent) {
      assert(!_hitTests.containsKey(event.pointer));
      result = HitTestResult();
      _hitTests[event.pointer] = result;
      assert(() {
        if (debugPrintHitTestResults) debugPrint('$event: $result');
        return true;
      }());
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      result = _hitTests.remove(event.pointer)!;
    } else if (event.down) {
      result = _hitTests[event.pointer]!;
    } else {
      return; // We currently ignore add, remove, and hover move events.
    }
    dispatchEvent(event, result);
  }
}