// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieInfoAdapter extends TypeAdapter<MovieInfo> {
  @override
  final typeId = 1;

  @override
  MovieInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieInfo(
      movieId: fields[0] as String?,
      movieName: fields[1] as String?,
      movieImg: fields[2] as String?,
      movieType: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.movieId)
      ..writeByte(1)
      ..write(obj.movieName)
      ..writeByte(2)
      ..write(obj.movieImg)
      ..writeByte(3)
      ..write(obj.movieType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
