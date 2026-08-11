// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonInfoAdapter extends TypeAdapter<PersonInfo> {
  @override
  final typeId = 0;

  @override
  PersonInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonInfo(
      nickName: fields[0] as String,
      avatarSVG: fields[1] as String,
      favourite: (fields[2] as List?)?.cast<MovieInfo>(),
      viewingRecord: (fields[3] as List?)?.cast<MovieInfo>(),
      browsingRecord: (fields[4] as List?)?.cast<MovieInfo>(),
    );
  }

  @override
  void write(BinaryWriter writer, PersonInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.nickName)
      ..writeByte(1)
      ..write(obj.avatarSVG)
      ..writeByte(2)
      ..write(obj.favourite)
      ..writeByte(3)
      ..write(obj.viewingRecord)
      ..writeByte(4)
      ..write(obj.browsingRecord);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
