import 'package:hive_ce/hive.dart';

part 'movie_info.g.dart';

class MovieAdapter extends TypeAdapter<MovieInfo> {
  @override
  final typeId = 1;

  @override
  MovieInfo read(BinaryReader reader) {
    return MovieInfo(movieId: reader.readString(),
        movieName: reader.readString(), movieImg: reader.readString(),
        movieType: reader.readString());
  }

  @override
  void write(BinaryWriter writer, MovieInfo obj) {
    writer.writeString(obj.movieId ?? '-1');
    writer.writeString(obj.movieName ?? 'unknown');
    writer.writeString(obj.movieImg ?? '');
    writer.writeString(obj.movieType ?? '');
  }
}

@HiveType(typeId: 1)
class MovieInfo {
  MovieInfo({required this.movieId, required this.movieName, required this.movieImg,
    required this.movieType});

  @HiveField(0)
  final String? movieId;

  @HiveField(1)
  final String? movieName;

  @HiveField(2)
  final String? movieImg;

  @HiveField(3)
  final String? movieType;
}