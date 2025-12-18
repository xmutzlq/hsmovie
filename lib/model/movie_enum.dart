/// 影视类型
enum MovieType {
  film('电影', '1'),
  series('连续剧', '2'),
  show('综艺', '3'),
  cartoon('动漫', '4');

  final String name;
  final String type;
  const MovieType(this.name, this.type);
}

/// 电影类型
enum FilmType {
  all('全部', '1'),
  action('动作片', '5'),
  show('喜剧片', '6'),
  comedy('爱情片', '7'),
  science('科幻片', '8'),
  horror('恐怖片', '9'),
  feature('剧情片', '10'),
  war('战争片', '11'),
  documentary('纪录片', '17'),
  adventure('冒险片', '18'),
  suspense('悬疑片', '19'),
  crime('犯罪片', '20'),
  thriller('惊悚片', '26'),
  animation('动画片', '27'),
  micro('微电影', '16'),
  other('其他片', '25');

  final String name;
  final String type;
  const FilmType(this.name, this.type);

  static bool containsType(String type) {
    return values.any((film) => film.type == type);
  }
}

/// 连续剧类型
enum SerialType {
  all('全部', '2'),
  c_drama('国产剧', '12'),
  hk_tw_drama('港台剧', '13'),
  j_k_drama('日韩剧', '14'),
  e_a_drama('欧美剧', '15'),
  other('其他剧', '29');

  final String name;
  final String type;
  const SerialType(this.name, this.type);
}

/// 动漫剧类型
enum AnimateType {
  all('全部', '4'),
  c_animate('国产动漫', '30'),
  j_animate('日本动漫', '31'),
  e_a_animate('欧美动漫', '32'),
  other('其他动漫', '33');

  final String name;
  final String type;
  const AnimateType(this.name, this.type);
}

/// 记录类型
enum RecordType {
  unknown('未知', '-1'),
  favourite('收藏', '1'),
  viewingRecord('观看记录', '2'),
  browsingRecord('浏览记录', '3');

  final String name;
  final String type;
  const RecordType(this.name, this.type);
}