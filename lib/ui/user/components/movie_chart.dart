
import 'package:ble_project/base/log/app_log.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:ble_project/ui/user/personal/model/moive_typs_statistics.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:save_points_chart/save_points_chart.dart';

Widget buildViewingRecordChart() {
  return GetBuilder<PersonalLogic>(
      id: 'movie_types_statistics', // 关键：为每个item指定唯一ID
      builder: (controller) {
        MovieTypeStatistics statistics111 = controller.personState.statistics;
        double movieFilterLength = (statistics111.movieFilter?.length ?? 0).toDouble();
        double tvFilterLength = (statistics111.tvFilter?.length ?? 0).toDouble();
        double showFilterLength = (statistics111.showFilter?.length ?? 0).toDouble();
        double cartoonFilterLength = (statistics111.cartoonFilter?.length ?? 0).toDouble();

        debugPrint('movieFilterLength : $movieFilterLength, tvFilterLength : $tvFilterLength,'
            ' showFilterLength : $showFilterLength, cartoonFilterLength : $cartoonFilterLength');

        List<PieData> _pieList = [];
        if(movieFilterLength > 0) {
          _pieList.add(PieData(
            label: '电影',
            value: movieFilterLength,
            color: Color(0xFF6366F1),
          ));
        }

        if(tvFilterLength > 0) {
          _pieList.add(PieData(
            label: '连续剧',
            value: tvFilterLength,
            color: Color(0xFF10B981),
          ));
        }

        if(showFilterLength > 0) {
          _pieList.add(PieData(
            label: '综艺',
            value: showFilterLength,
            color: Color(0xFFEC4899),
          ));
        }

        if(cartoonFilterLength > 0) {
          _pieList.add(PieData(
            label: '动漫',
            value: cartoonFilterLength,
            color: Color(0xFFEC4833),
          ));
        }

        if(_pieList.length == 0) {
          return screenEmptyStateForCard();
        } else {
          return DonutChartWidget(
            data: _pieList,
            theme: ChartTheme.fromMaterialTheme(appThemeData).copyWith(
                backgroundColor: Colors.white54, borderRadius: 10),
            title: '观看记录统计',
            isError: _pieList.length == 0,
            centerSpaceRadius: 50,
            onSegmentTap: (segment, index, position) {
              logI('Tapped: ${segment.label} - Value: ${segment.value}');
            },
          );
        }
      }
  );
}