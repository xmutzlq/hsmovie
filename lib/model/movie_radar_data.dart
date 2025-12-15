class MovieRadarData {
  final String id;
  final String name;
  double size;

  MovieRadarData({
    required this.id,
    required this.name,
    this.size = 0,
  });

  // 复制并修改
  MovieRadarData copyWith({
    String? id,
    String? name,
    double? size,
  }) {
    return MovieRadarData(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
    );
  }

  // 从Map转换
  factory MovieRadarData.fromMap(Map<String, dynamic> map) {
    return MovieRadarData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      size: map['size'] ?? 0,
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
    };
  }

  @override
  String toString() {
    return 'MovieRadarData(id: $id, name: $name, size: $size)';
  }
}