enum MovieType {
  film('电影', '1'),
  series('连续剧', '2'),
  show('综艺', '3'),
  cartoon('动漫', '4');

  final String name;
  final String type;
  const MovieType(this.name, this.type);
}