import 'dart:convert';

import 'package:ble_project/model/player/playback_models.dart';
import 'package:dio/dio.dart';

class CmsVideoApi {
  static const List<CmsSourceConfig> defaultSources = [
    CmsSourceConfig(
      id: 'lzi',
      name: '量子资源',
      api: 'https://cj.lziapi.com/api.php/provide/vod/',
      priority: 10,
    ),
    CmsSourceConfig(
      id: 'bdzy',
      name: '百度云资源',
      api: 'https://api.apibdzy.com/api.php/provide/vod/',
      priority: 9,
    ),
    CmsSourceConfig(
      id: 'wjzy',
      name: '无尽资源',
      api: 'https://api.wujinapi.com/api.php/provide/vod/',
      priority: 8,
    ),
  ];

  final Dio _dio;
  final List<CmsSourceConfig> sources;

  CmsVideoApi({Dio? dio, this.sources = defaultSources})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 5),
              headers: const {'User-Agent': 'hsmovie/1.0'},
            ),
          );

  Future<List<CmsSearchResult>> searchAll(String keyword) async {
    final requests = sources.map((source) => search(source, keyword));
    final resultGroups = await Future.wait(requests);
    return resultGroups.expand((group) => group).toList();
  }

  Future<List<CmsSearchResult>> search(
    CmsSourceConfig source,
    String keyword,
  ) async {
    try {
      final response = await _dio
          .get<dynamic>(
            source.api,
            queryParameters: {'ac': 'detail', 'wd': keyword, 'pg': 1},
            options: Options(headers: source.headers),
          )
          .timeout(const Duration(seconds: 8));
      final root = decodeObject(response.data);
      final list = root?['list'];
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((item) {
            final json = Map<String, dynamic>.from(item);
            return CmsSearchResult(
              source: source,
              mediaId: valueAsString(json['vod_id']),
              title: valueAsString(json['vod_name']),
              year: valueAsString(json['vod_year']),
            );
          })
          .where((item) => item.mediaId.isNotEmpty && item.title.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> detail(CmsSearchResult result) async {
    try {
      final response = await _dio
          .get<dynamic>(
            result.source.api,
            queryParameters: {'ac': 'detail', 'ids': result.mediaId},
            options: Options(headers: result.source.headers),
          )
          .timeout(const Duration(seconds: 8));
      final root = decodeObject(response.data);
      final list = root?['list'];
      if (list is! List || list.isEmpty || list.first is! Map) return null;
      return Map<String, dynamic>.from(list.first as Map);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? decodeObject(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String valueAsString(dynamic value) => value?.toString().trim() ?? '';
}
