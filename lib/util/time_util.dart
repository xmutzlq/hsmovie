class TimeUtil {
  static String timeStampToTimeStr(int timeStamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000).toString();
    return dateTime.length > 4 ? (dateTime.substring(0, dateTime.length - 4)) : dateTime;
  }
}