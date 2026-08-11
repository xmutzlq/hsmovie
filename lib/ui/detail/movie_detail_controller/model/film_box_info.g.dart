// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_box_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilmBoxInfoAdapter extends TypeAdapter<FilmBoxInfo> {
  @override
  final typeId = 2;

  @override
  FilmBoxInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilmBoxInfo(filmBoxRecord: (fields[0] as List?)?.cast<MovieInfo>());
  }

  @override
  void write(BinaryWriter writer, FilmBoxInfo obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.filmBoxRecord);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilmBoxInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
