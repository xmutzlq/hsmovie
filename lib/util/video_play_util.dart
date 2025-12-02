/// 视频播放器工具类
class VideoPlayUtil {
  bool checkPlayFormate(String? url) {
    if (url?.isEmpty ?? true) {
      return false;
    }
    // 检查是否是直接视频地址
    if (url!.endsWith('.mp4') ||
        url.endsWith('.m3u8') ||
        url.endsWith('.flv')) {
      return true;
    }

    return false;
  }


}