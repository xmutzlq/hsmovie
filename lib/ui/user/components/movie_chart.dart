
import 'package:ble_project/base/log/app_log.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/model/movie_enum.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:ble_project/ui/user/personal/model/moive_typs_statistics.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:ble_project/widget/fix_donut_chart_widget.dart';
import 'package:ble_project/widget/fix_radial_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:save_points_chart/save_points_chart.dart';

void _showRadarStatisticsDialog(MovieType movieType) {
  SmartDialog.show(
    builder: (context) =>
      Stack(
        children: [
          _buildRadarStatisticsChart(movieType),
          Positioned(
            top: 6.0,
            right: 15.0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                SmartDialog.dismiss();
              },
            ),
          )
        ]
      ));
}

Widget _buildRadarStatisticsChart(MovieType movieType) {
  debugPrint('movieType : $movieType');
  return GetBuilder<PersonalLogic>(
    id: 'movie_radar_statistics', // 关键：为每个item指定唯一ID
    builder: (controller) {
      controller.analysisMovieRadarTypes(movieType);
      final chartDataPointX = 0.0;
      var movieTypeStr = '您的观看偏好';
      var color = Colors.white60;
      List<ChartDataPoint> radars = [];
      switch(movieType) {
        case MovieType.film:
          movieTypeStr = '您的电影观看偏好';
          color = Color(0xFF6366F1);
          controller.personState.statistics.filmRadarCategories.forEach((element) {
            radars.add(ChartDataPoint(x: chartDataPointX, y: element.size, label: element.name,));
          });
          break;
        case MovieType.series:
          movieTypeStr = '您的电视剧观看偏好';
          color = Color(0xFF10B981);
          controller.personState.statistics.serialRadarCategories.forEach((element) {
            radars.add(ChartDataPoint(x: chartDataPointX, y: element.size, label: element.name,));
          });
          break;
        case MovieType.cartoon:
          movieTypeStr = '您的动漫观看偏好';
          color = Color(0xFFEC4833);
          controller.personState.statistics.animateRadarCategories.forEach((element) {
            radars.add(ChartDataPoint(x: chartDataPointX, y: element.size, label: element.name,));
          });
          break;
        case MovieType.show:
          movieTypeStr = '您的综艺观看偏好';
          color = Color(0xFFEC4899);
          break;
      }
      debugPrint('radars : $radars');
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: FixRadialChartWidget(dataSets: [
          ChartDataSet(
            label: movieTypeStr,
            color: color,
            dataPoints: radars,
          ),
        ],
          lineWidth: 2,
          title: movieTypeStr
        )
      );
    }
  );
}

Widget buildRecordStatisticsChart() {
  return GetBuilder<PersonalLogic>(
      id: 'movie_types_statistics', // 关键：为每个item指定唯一ID
      builder: (controller) {
        String recordName = controller.personState.currentRecordType.name;

        MovieTypeStatistics statistics111 = controller.personState.statistics;
        double movieFilterLength = (statistics111.movieFilter?.length ?? 0).toDouble();
        double tvFilterLength = (statistics111.tvFilter?.length ?? 0).toDouble();
        double showFilterLength = (statistics111.showFilter?.length ?? 0).toDouble();
        double cartoonFilterLength = (statistics111.cartoonFilter?.length ?? 0).toDouble();

        debugPrint('movieFilterLength : $movieFilterLength, tvFilterLength : $tvFilterLength,'
            ' showFilterLength : $showFilterLength, cartoonFilterLength : $cartoonFilterLength');

        bool haveRecord = movieFilterLength > 0 || tvFilterLength > 0
            || showFilterLength > 0 || cartoonFilterLength > 0;

        List<PieData> _pieList = [];

        if(haveRecord) {
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
        }
        if(_pieList.length == 0) {
          return screenEmptyStateForCard('暂无$recordName');
        } else {
          return FixDonutChartWidget(
            data: _pieList,
            theme: ChartTheme.fromMaterialTheme(appThemeData).copyWith(
                backgroundColor: Colors.white54, borderRadius: 10),
            title: '$recordName统计',
            centerTitle: '总数',
            centerSpaceRadius: 50,
            onSegmentTap: (segment, index, position) {
              debugPrint('Tapped: ${segment.label} - Value: ${segment.value}');
              if(segment.label == MovieType.film.name) {
                _showRadarStatisticsDialog(MovieType.film);
              } else if(segment.label == MovieType.series.name) {
                _showRadarStatisticsDialog(MovieType.series);
              } else if(segment.label == MovieType.cartoon.name) {
                _showRadarStatisticsDialog(MovieType.cartoon);
              }
            },
          );
        }
      }
  );
}