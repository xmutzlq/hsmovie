// ignore_for_file: file_names

import 'dart:async';

import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/fix_scroll_shadow.dart';
import 'package:flutter/material.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'dlna_dialog.dart';

Map<String, DLNADevice> cacheDeviceList = {};

void showDlnaDevicePicker({String? videoId, String mediaTitle = ''}) {
  final castController = DlnaCastOverlayController.instance;
  if (castController.hasActiveSession) {
    castController.restore();
    return;
  }
  SmartDialog.show(
    debounce: true,
    clickMaskDismiss: false,
    builder: (_) => Container(
      height: Get.height * 2 / 3,
      width: Get.width - 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: DlnaDeviceList(videoId: videoId, mediaTitle: mediaTitle),
    ),
  );
}

class DlnaDeviceList extends StatefulWidget {
  final String? videoId;
  final String mediaTitle;
  const DlnaDeviceList({super.key, this.videoId, this.mediaTitle = ''});

  @override
  State<StatefulWidget> createState() {
    return _DlnaDeviceListState();
  }
}

class _DlnaDeviceListState extends State<DlnaDeviceList> {
  late DLNAManager searcher;
  late final DeviceManager m;
  Map<String, DLNADevice> deviceList = {};
  _DlnaDeviceListState();

  @override
  initState() {
    super.initState();
    debugPrint('dlna_device_list_widget_init');
    searcher = DLNAManager();
    init();
  }

  Future<void> init() async {
    m = await searcher.start();
    m.devices.stream.listen((dList) {
      dList.forEach((key, value) {
        cacheDeviceList[key] = value;
      });
      setState(() {
        deviceList = cacheDeviceList;
      });
    });
    await _pullToRefresh();
  }

  @override
  void dispose() {
    searcher.stop();
    super.dispose();
    debugPrint('dlna_device_list_widget_dispose');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: _pullToRefresh, child: _bodyContain());
  }

  Future _pullToRefresh() async {
    m.deviceList.forEach((key, value) {
      cacheDeviceList[key] = value;
    });
    setState(() {
      deviceList = cacheDeviceList;
    });
  }

  Widget _bodyContain() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 0, left: 15, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择设备',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 100, 135),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  SmartDialog.dismiss();
                },
              ),
            ],
          ),
          Expanded(child: _body()),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _body() {
    // deviceList = {};
    if (deviceList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              '正在搜索设备...',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 135),
              ),
            ),
          ],
        ),
      );
    }
    final List<Widget> dList = [];
    deviceList.entries.toList().asMap().forEach((index, entry) {
      dList.add(_buildItem(index, entry.key, entry.value));
    });

    return FixScrollShadow(
      color: Colors.black.withAlpha(20),
      child: ListView(children: dList, padding: EdgeInsets.zero),
    );
  }

  Widget _buildItem(int index, String uri, DLNADevice device) {
    final title = device.info.friendlyName;
    final subtitle = '$uri\r\n${device.info.deviceType}';
    final s = subtitle.toLowerCase();
    var icon = Icons.wifi;
    final support =
        s.contains("mediarenderer") ||
        s.contains("avtransport") ||
        s.contains('mediaserver');
    if (!support) {
      icon = Icons.router;
    }
    final card = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : 16,
              left: 16,
              bottom: 30,
            ),
            child: CircleAvatar(child: Icon(icon)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 16, top: 10),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 100, 135),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 16,
                    right: 16,
                    bottom: 10,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          subtitle,
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 100, 100, 135),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 0, left: 0, right: 0),
        child: InkWell(
          child: card,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: () async {
            if (!support) {
              const msg = "该设备不支持投屏";
              ToastUtil.showToast(msg);
              return;
            }
            await SmartDialog.dismiss();
            await DlnaCastOverlayController.instance.open(
              device,
              videoId: widget.videoId,
              mediaTitle: widget.mediaTitle,
            );
          },
        ),
      ),
    );
  }
}
