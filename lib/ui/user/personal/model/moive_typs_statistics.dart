
import 'package:ble_project/model/movie_enum.dart';
import 'package:ble_project/model/movie_radar_data.dart';
import 'package:ble_project/ui/user/personal/model/movie_info.dart';

class MovieTypeStatistics {
  List<MovieInfo>? movieFilter = [];
  List<MovieInfo>? tvFilter = [];
  List<MovieInfo>? showFilter = [];
  List<MovieInfo>? cartoonFilter = [];

  void clear() {
    movieFilter?.clear();
    tvFilter?.clear();
    showFilter?.clear();
    cartoonFilter?.clear();
  }

  // 初始化雷达图分类数据
  List<MovieRadarData> orgFilmRadarCategories = [
    MovieRadarData(id: FilmType.action.type, name: FilmType.action.name, size: 0),
    MovieRadarData(id: FilmType.show.type, name: FilmType.show.name, size: 0),
    MovieRadarData(id: FilmType.comedy.type, name: FilmType.comedy.name, size: 0),
    MovieRadarData(id: FilmType.science.type, name: FilmType.science.name, size: 0),
    MovieRadarData(id: FilmType.horror.type, name: FilmType.horror.name, size: 0),
    MovieRadarData(id: FilmType.feature.type, name: FilmType.feature.name, size: 0),
    MovieRadarData(id: FilmType.war.type, name: FilmType.war.name, size: 0),
    MovieRadarData(id: FilmType.documentary.type, name: FilmType.documentary.name, size: 0),
    MovieRadarData(id: FilmType.adventure.type, name: FilmType.adventure.name, size: 0),
    MovieRadarData(id: FilmType.suspense.type, name: FilmType.suspense.name, size: 0),
    MovieRadarData(id: FilmType.crime.type, name: FilmType.crime.name, size: 0),
    MovieRadarData(id: FilmType.thriller.type, name: FilmType.thriller.name, size: 0),
    MovieRadarData(id: FilmType.animation.type, name: FilmType.animation.name, size: 0),
    MovieRadarData(id: FilmType.micro.type, name: FilmType.micro.name, size: 0),
  ];

  List<MovieRadarData> get filmRadarCategories => orgFilmRadarCategories;

  void resetFilmRadarSize() {
    orgFilmRadarCategories.forEach((element) => element.size = 0);
  }

  List<MovieRadarData> orgSerialRadarCategories = [
    MovieRadarData(id: SerialType.c_drama.type, name: SerialType.c_drama.name, size: 0),
    MovieRadarData(id: SerialType.hk_tw_drama.type, name: SerialType.hk_tw_drama.name, size: 0),
    MovieRadarData(id: SerialType.j_k_drama.type, name: SerialType.j_k_drama.name, size: 0),
    MovieRadarData(id: SerialType.e_a_drama.type, name: SerialType.e_a_drama.name, size: 0),
  ];

  List<MovieRadarData> get serialRadarCategories => orgSerialRadarCategories;

  void resetSerialRadarSize() {
    orgSerialRadarCategories.forEach((element) => element.size = 0);
  }

  List<MovieRadarData> orgAnimateRadarCategories = [
    MovieRadarData(id: AnimateType.c_animate.type, name: AnimateType.c_animate.name, size: 0),
    MovieRadarData(id: AnimateType.j_animate.type, name: AnimateType.j_animate.name, size: 0),
    MovieRadarData(id: AnimateType.e_a_animate.type, name: AnimateType.e_a_animate.name, size: 0),
  ];

  List<MovieRadarData> get animateRadarCategories => orgAnimateRadarCategories;

  void resetAnimateRadarSize() {
    orgAnimateRadarCategories.forEach((element) => element.size = 0);
  }
}