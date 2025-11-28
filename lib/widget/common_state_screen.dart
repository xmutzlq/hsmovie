import 'package:ble_project/base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget screenLoadingState() {
  return Container(
    color: commBgColor,
    child: const Center(
      child: const CircularProgressIndicator(),
    )
  );
}

Widget screenErrorState(String? error) {
  return Container(
      color: commBgColor,
      child: Center(
          child: Column(
            children: [
              SvgPicture.asset('assets/page_error.svg', semanticsLabel: 'PageError Logo'),
              Text(error ?? "error msg null")
            ],
          )
      )
  );
}

Widget screenEmptyState() {
  return Container(
      color: commBgColor,
      child: Center(
          child: Column(
            children: [
              SvgPicture.asset('assets/page_empty.svg', semanticsLabel: 'PageEmpty Logo'),
              const Text('暂无数据')
            ],
          )
      )
  );
}