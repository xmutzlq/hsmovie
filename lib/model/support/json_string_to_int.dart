import 'package:json_annotation/json_annotation.dart' show JsonConverter;

class JsonStringToInt implements JsonConverter<int, dynamic> {
  const JsonStringToInt();

  @override
  int fromJson(dynamic json) {
    if (json is num) {
      return json.toInt();
    }
    if(json == null) {
      return 0;
    }
    return int.tryParse(json) ?? 0;
  }

  @override
  String toJson(int object) => object.toString();
}