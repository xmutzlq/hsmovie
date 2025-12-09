import 'package:hive_ce/hive.dart';
import 'movie_info.dart';

part 'person_info.g.dart';

class PersonAdapter extends TypeAdapter<PersonInfo> {
  @override
  final typeId = 0;

  @override
  PersonInfo read(BinaryReader reader) {
    final movies = reader.readList().cast<MovieInfo>();
    return PersonInfo(nickName: reader.readString(),
        avatarSVG: reader.readString(), favourite: movies);
  }

  @override
  void write(BinaryWriter writer, PersonInfo obj) {
    writer.writeString(obj.nickName);
    writer.writeString(obj.avatarSVG);
    writer.writeList(obj.favourite?.cast<MovieInfo>() ?? []);
  }
}

@HiveType(typeId: 0)
class PersonInfo {
  PersonInfo({required this.nickName, required this.avatarSVG, required this.favourite});

  @HiveField(0)
  final String nickName;

  @HiveField(1)
  final String avatarSVG;

  @HiveField(2)
  final List<MovieInfo>? favourite;

  // 添加 copyWith 方法
  PersonInfo copyWith({
    String? nickName,
    String? avatarSVG,
    List<MovieInfo>? favourite,
  }) {
    return PersonInfo(
      nickName: nickName ?? '', // 如果新参数为null，则使用原值
      avatarSVG: avatarSVG ?? '',
      favourite: favourite ?? [],
    );
  }
}