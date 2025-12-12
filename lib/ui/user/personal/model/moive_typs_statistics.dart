
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
}