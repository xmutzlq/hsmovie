import 'package:hive_ce/hive.dart';
import 'movie_info.dart';

part 'person_info.g.dart';

class PersonAdapter extends TypeAdapter<PersonInfo> {
  @override
  final typeId = 0;

  @override
  PersonInfo read(BinaryReader reader) {
    final fMovies = reader.readList().cast<MovieInfo>();
    final vMovies = reader.readList().cast<MovieInfo>();
    final bMovies = reader.readList().cast<MovieInfo>();
    return PersonInfo(nickName: reader.readString(), avatarSVG: reader.readString(),
        favourite: fMovies, viewingRecord: vMovies, browsingRecord: bMovies);
  }

  @override
  void write(BinaryWriter writer, PersonInfo obj) {
    writer.writeString(obj.nickName);
    writer.writeString(obj.avatarSVG);
    writer.writeList(obj.favourite?.cast<MovieInfo>() ?? []);
    writer.writeList(obj.viewingRecord?.cast<MovieInfo>() ?? []);
    writer.writeList(obj.browsingRecord?.cast<MovieInfo>() ?? []);
  }
}

@HiveType(typeId: 0)
class PersonInfo {
  PersonInfo({required this.nickName, required this.avatarSVG,
    required this.favourite, required this.viewingRecord, required this.browsingRecord});

  @HiveField(0)
  final String nickName;

  @HiveField(1)
  final String avatarSVG;

  @HiveField(2)
  final List<MovieInfo>? favourite;

  @HiveField(3)
  final List<MovieInfo>? viewingRecord;

  @HiveField(4)
  final List<MovieInfo>? browsingRecord;

  // 添加 copyWith 方法
  PersonInfo copyWith({
    String? nickName,
    String? avatarSVG,
    List<MovieInfo>? favourite,
    List<MovieInfo>? viewingRecord,
    List<MovieInfo>? browsingRecord,
  }) {
    return PersonInfo(
      nickName: nickName ?? '', // 如果新参数为null，则使用原值
      avatarSVG: avatarSVG ?? '',
      favourite: favourite ?? [],
      viewingRecord: viewingRecord ?? [],
      browsingRecord: browsingRecord ?? [],
    );
  }
}