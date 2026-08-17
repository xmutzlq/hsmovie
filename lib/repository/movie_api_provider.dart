import 'package:ble_project/base/dio_new.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class MovieApiProvider {
  HttpClient dio = Get.find<HttpClient>();

  ///首页数据
  Future<HttpResponse> getHome() async {
    final HttpResponse appResponse = await dio.get("v1/home-list");
    return appResponse;
  }

  /// type[1-电影；2-连续剧；3-综艺]
  Future<HttpResponse> getMovie(String type) async {
    if (kIsWeb) {
      return dio.get("v1/list-by-type", queryParameters: {'type': type});
    }
    final HttpResponse appResponse = await dio.get(
      "v1/list-by-type?type=$type",
    );
    return appResponse;
  }

  /// type[vod_hits_week-周版；vod_hits_month-月版；vod_hits-总版]
  Future<HttpResponse> getRanking(String type) async {
    final HttpResponse appResponse = await dio.get("v1/rank-list?cate=$type");
    return appResponse;
  }

  ///可能的搜索结果
  Future<HttpResponse> getSearchSuggestions(String keyword) async {
    final HttpResponse appResponse = await dio.get(
      "v1/auto-search?keyword=$keyword",
    );
    return appResponse;
  }

  ///分页搜索结果
  Future<HttpResponse> getSearchResultByPage(
    String keyword,
    String page,
  ) async {
    final HttpResponse appResponse = await dio.get(
      "v1/search?keyword=$keyword&cate=undefined&page=$page",
    );
    return appResponse;
  }

  ///影片详情
  Future<HttpResponse> getMovieDetail(String movieId) async {
    if (kIsWeb) {
      return dio.get("v1/vod-details", queryParameters: {'id': movieId});
    }
    final HttpResponse appResponse = await dio.get(
      "v1/vod-details?id=$movieId",
    );
    return appResponse;
  }

  ///所有分类
  Future<HttpResponse> getAllFilters() async {
    final HttpResponse appResponse = await dio.get("v1/vod-list-options");
    return appResponse;
  }

  ///更多结果
  Future<HttpResponse> getMoreData(int type, int page) async {
    if (kIsWeb) {
      return dio.get(
        "v1/vod-list",
        queryParameters: {
          'orderBy': '',
          'type': type,
          'class': '',
          'area': '',
          'year': '',
          'lang': '',
          'letter': '',
          'page': page,
        },
      );
    }
    final HttpResponse appResponse = await dio.get(
      "v1/vod-list?orderBy=&type=$type&class=&area=&year=&lang=&letter=&page=$page",
    );
    return appResponse;
  }

  ///获取播放url中隐藏的播放地址
  Future<String?> getPlayUrl(String url) async {
    try {
      final response = await Dio().get(url);
      // logD('response : $response');
      if (response.data is String) {
        return getVideoUrl(response.data as String);
      }
      return url;
    } on DioException catch (e) {
      return url;
    }
  }

  String? getVideoUrl(String html) =>
      RegExp(r"video_url\s*=\s*'([^']+)'").firstMatch(html)?.group(1);
}
