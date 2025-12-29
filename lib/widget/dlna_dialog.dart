// ignore_for_file: file_names

import 'dart:async';

import 'package:ble_project/ui/player/player_controller/logic.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:zo_animated_border/widget/zo_breathing_border.dart';

import 'dlna_stream_items.dart';

class DlnaDialog extends StatefulWidget {
  final DLNADevice dev;
  final String? videoId;
  const DlnaDialog(this.dev, {super.key, this.videoId});

  @override
  State<StatefulWidget> createState() {
    return _DlnaDialogState();
  }
}

class _DlnaDialogState extends State<DlnaDialog> {
  static const OperateBtnWidth_80 = 80.0;
  static const OperateBtnWidth_100 = 100.0;
  static const OperateBtnHeight = 35.0;
  PositionParser? position;
  Timer timer = Timer(const Duration(seconds: 1), () {});

  @override
  void initState() {
    super.initState();
    callback(_) async {
      try {
        final text = await widget.dev.position();
        final p = PositionParser(text);
        setState(() {
          position = p;
        });
      } catch (e) {
        ToastUtil.showToast("update play progress failed: $e");
      }
    }

    // 每5秒执行一次更新
    timer = Timer.periodic(const Duration(seconds: 5), callback);
    callback(null);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bodyContain();
  }

  Widget _bodyContain() {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 0, left: 15, right: 10),
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 100, 135),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      // 关闭对话框，停止投屏
                      try {
                        await widget.dev.stop();
                      } catch (e) {
                        ToastUtil.showToast("$e");
                      }
                      SmartDialog.dismiss();
                    }
                  )
                ]
            ),
            Expanded(child: _body())
          ],
        )
    );
  }

  Widget _body() {
    final dialog = ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: Text(
            widget.dev.info.friendlyName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.topCenter,
          child: Text(
            widget.dev.info.URLBase,
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ),
        SizedBox(height: 15),
        SizedBox(child: buildCurrUri()),
        SizedBox(height: 20),
        buildActions(),
        SizedBox(height: 15)
      ],
    );

    return SizedBox(
      height: 430,
      width: MediaQuery.of(context).size.width - 100,
      child: dialog,
    );
  }

  Widget buildCurrUri() {
    debugPrint('traceUri : ${position?.TrackURI}');
    if (position == null || position!.TrackURI.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: const Text("暂无视频信息"),
      );
    }
    final List<Widget> sList = [];
    sList.add(
      const Align(
        alignment: Alignment.topLeft,
        child: Text("当前播放:", style: TextStyle(color: Colors.green)),
      ),
    );
    var currUrl = position!.TrackURI;
    if (currUrl.length > 100) {
      currUrl = '${currUrl.substring(0, 100)}...';
    }
    // 播放链接显示
    sList.add(
      Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Align(
          alignment: Alignment.topLeft,
          child: InkWell(
            child: Text(
              currUrl,
              style: const TextStyle(fontSize: 12, color: Colors.orange),
              textAlign: TextAlign.left,
            ),
            onTap: () {
              ClipboardData data = ClipboardData(text: position!.TrackURI);
              Clipboard.setData(data);
              ToastUtil.showToast("已复制");
            },
          ),
        ),
      ),
    );
    if (position!.AbsTime.isNotEmpty) {
      // 时间显示
      sList.add(
        Align(
          alignment: Alignment.topLeft,
          child: Text("${position!.AbsTime} / ${position!.TrackDuration}"),
        ),
      );
    }

    return ZoBreathingBorder(
      borderWidth: 2.0,
      borderRadius: BorderRadius.circular(10),
      colors: [
        Colors.blue,
        Colors.purple,
        Colors.red,
        Colors.orange,
      ],
      animationDuration: const Duration(seconds: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sList)
      )
    );
  }

  Widget buildActions() {
    const style = TextStyle(fontSize: 12);
    final push = ElevatedButton(
      child: const Text("投屏"),
      onPressed: () async {

        if(widget.videoId != null && widget.videoId!.isNotEmpty) {
          SmartDialog.show(
            alignment: Alignment.bottomCenter,
            builder: (_) {
              return DlnaStreamItems(widget.dev, widget.videoId!);
            },
          );
        } else {
          final logic = Get.find<PlayerControllerLogic>();
          var url = logic.currentPlayUrl;
          try {
            await widget.dev.setUrl(url);
            await widget.dev.play();
          } catch (e) {
            ToastUtil.showToast("投屏失败：$e");
          }
          Timer(const Duration(seconds: 2), () async {
            final text = await widget.dev.position();
            position = PositionParser(text);
          });
        }
      }
    );
    final play = SizedBox(
      width: OperateBtnWidth_80,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await widget.dev.play();
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("播放", style: style),
      ),
    );
    final pause = SizedBox(
      width: OperateBtnWidth_80,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await widget.dev.pause();
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("暂停", style: style),
      ),
    );
    final stop = SizedBox(
      width: OperateBtnWidth_80,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await widget.dev.stop();
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("停止", style: style),
      ),
    );
    final prev10 = SizedBox(
      width: OperateBtnWidth_100,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final curr = await widget.dev.position();
            final p = PositionParser(curr);
            setState(() {
              position = p;
            });
            widget.dev.seekByCurrent(curr, -10);
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("快退10秒", style: style),
      ),
    );
    final next10 = SizedBox(
      width: OperateBtnWidth_100,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final curr = await widget.dev.position();
            final p = PositionParser(curr);
            setState(() {
              position = p;
            });
            widget.dev.seekByCurrent(curr, 10);
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("快进10秒", style: style),
      ),
    );

    final prev30 = SizedBox(
      width: OperateBtnWidth_100,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final curr = await widget.dev.position();
            final p = PositionParser(curr);
            setState(() {
              position = p;
            });
            await widget.dev.seekByCurrent(curr, -30);
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("快退30秒", style: style),
      ),
    );
    final next30 = SizedBox(
      width: OperateBtnWidth_100,
      height: OperateBtnHeight,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final curr = await widget.dev.position();
            final p = PositionParser(curr);
            setState(() {
              position = p;
            });
            await widget.dev.seekByCurrent(curr, 30);
          } catch (e) {
            ToastUtil.showToast("$e");
          }
        },
        child: const Text("快进30秒", style: style),
      ),
    );

    return Column(
      children: [
        OverflowBar(alignment: MainAxisAlignment.center, children: [push]),
        const SizedBox(height: 20),
        OverflowBar(
          alignment: MainAxisAlignment.center,
          children: [play, pause, stop],
          spacing: 10.0,
        ),
        const SizedBox(height: 15),
        OverflowBar(
          alignment: MainAxisAlignment.center,
          children: [next10, prev10],
          spacing: 10.0,
        ),
        const SizedBox(height: 15),
        OverflowBar(
          alignment: MainAxisAlignment.center,
          children: [next30, prev30],
          spacing: 10.0,
        ),
      ],
    );
  }
}