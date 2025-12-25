// ignore_for_file: file_names

import 'package:ble_project/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:dlna_dart/dlna.dart';

class DlnaStreamItems extends StatelessWidget {
  final DLNADevice dev;
  final String videoId;
  const DlnaStreamItems(this.dev, this.videoId, {super.key});

  String getUrl(int type) {
    final base = '${''.split(";").first}$videoId.webm';
    if (type == 1) {
      return "$base?prefer=18,59,22,37";
    } else if (type == 2) {
      return "$base?prefer=37,22,59,18";
    } else if (type == 3) {
      return "$base?prefer=251,250,140,599";
    }
    return "$base?prefer=247,244,243,136,135";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: const Text("标清"),
              ),
            ],
          ),
          onTap: () async {
            try {
              await dev.setUrl(getUrl(1));
              await dev.play();
            } catch (e) {
              ToastUtil.showToast( "$e");
            }
          },
        ),
        InkWell(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: const Text("高清"),
              ),
            ],
          ),
          onTap: () async {
            try {
              await dev.setUrl(getUrl(2));
              await dev.play();
            } catch (e) {
              ToastUtil.showToast( "$e");
            }
          },
        ),
        InkWell(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: const Text("仅音频模式"),
              ),
            ],
          ),
          onTap: () async {
            try {
              await dev.setUrl(getUrl(3));
              await dev.play();
            } catch (e) {
              ToastUtil.showToast( "$e");
            }
          },
        ),
        InkWell(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: const Text("仅视频模式"),
              ),
            ],
          ),
          onTap: () async {
            try {
              await dev.setUrl(getUrl(4));
              await dev.play();
            } catch (e) {
              ToastUtil.showToast( "$e");
            }
          },
        ),
      ],
    );
  }
}