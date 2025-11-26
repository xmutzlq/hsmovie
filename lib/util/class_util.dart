/// 工具类
class ClazzUtil {
  static String getClassName(Object? obj) {
    return obj?.runtimeType.toString() ?? "";
  }
}