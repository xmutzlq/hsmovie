import 'package:ble_project/base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

Widget screenLoadingState() {
  return Container(
    color: commBgColor,
    child: const Center(child: const CircularProgressIndicator()),
  );
}

Widget screenLoadingStateForTabView() {
  return IntrinsicHeight(
    child: Column(
      children: [
        Expanded(child: SizedBox()),
        Expanded(child: const CircularProgressIndicator()),
        Expanded(child: SizedBox())
      ],
    ),
  );
}

Widget screenErrorState(String? error) {
  debugPrint("buildResults -> screenErrorState error : $screenErrorState");
  return Container(
    color: Colors.white,
    width: Get.width,
    height: Get.height,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/page_error.svg',
          width: 150,
          height: 150,
          semanticsLabel: 'PageError Logo',
        ),
        SizedBox(height: 15),
        Text(error ?? "error msg null"),
        SizedBox(height: 140),
      ],
    ),
  );
}

Widget screenEmptyStateFull() {
  return Container(
    color: Colors.white,
    width: Get.width,
    height: Get.height,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/page_empty.svg',
          width: 150,
          height: 150,
          semanticsLabel: 'PageEmpty Logo',
        ),
        SizedBox(height: 15),
        const Text('暂无数据'),
        SizedBox(height: 140),
      ],
    ),
  );
}

Widget screenEmptyState() {
  return Container(
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/page_empty.svg',
          width: 150,
          height: 150,
          semanticsLabel: 'PageEmpty Logo',
        ),
        SizedBox(height: 15),
        const Text('暂无数据'),
      ],
    ),
  );
}

Widget screenEmptyStateForTabView() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/page_empty.svg',
          width: 150,
          height: 150,
          semanticsLabel: 'PageEmpty Logo',
        ),
        SizedBox(height: 15),
        const Text('暂无播放源，请切换到其他播放源'),
      ],
    ),
  );
}

Widget screenEmptyStateForTabViewDark() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/page_empty.svg',
          width: 150,
          height: 150,
          semanticsLabel: 'PageEmpty Logo',
        ),
        SizedBox(height: 15),
        const Text('暂无播放源，请切换到其他播放源', style: TextStyle(color: Colors.white)),
      ],
    ),
  );
}

Widget screenEmptyStateForCard() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 15),
        SvgPicture.asset(
          'assets/page_empty.svg',
          width: 150,
          height: 150,
          semanticsLabel: 'PageEmpty Logo',
        ),
        SizedBox(height: 15),
        const Text('暂无播放源，请切换到其他播放源'),
        SizedBox(height: 15),
      ],
    ),
  );
}
