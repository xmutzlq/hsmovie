import 'package:hive_ce/hive.dart';

import '../../../user/personal/model/movie_info.dart';

part 'film_box_info.g.dart';

@HiveType(typeId: 2)
class FilmBoxInfo {
  FilmBoxInfo({required this.filmBoxRecord});

  @HiveField(0)
  final List<MovieInfo>? filmBoxRecord;

  // 添加 copyWith 方法
  FilmBoxInfo copyWith({
    List<MovieInfo>? filmBoxRecord,
  }) {
    return FilmBoxInfo(
      filmBoxRecord: filmBoxRecord ?? [],
    );
  }
}