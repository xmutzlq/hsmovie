import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';

import 'http_config.dart';

class AppDio with DioMixin implements Dio {
  AppDio({BaseOptions? options, HttpConfig? dioConfig}) {
    options ??= BaseOptions(
      baseUrl: dioConfig?.baseUrl ?? '',
      contentType: 'application/json',
      connectTimeout: Duration(seconds: dioConfig!.connectTimeout),
      sendTimeout: Duration(seconds: dioConfig.sendTimeout),
      receiveTimeout: Duration(seconds: dioConfig.receiveTimeout),
    )..headers = dioConfig.headers;
    this.options = options;

    interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          hitCacheOnErrorCodes: const [401, 403],
          maxStale: const Duration(days: 7),
        ),
      ),
    );
    if (kDebugMode) {
      interceptors.add(
        LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
        ),
      );
    }
    if (dioConfig?.interceptors?.isNotEmpty ?? false) {
      interceptors.addAll(dioConfig!.interceptors!);
    }
    httpClientAdapter = BrowserHttpClientAdapter();
  }

  void setProxy(String proxy) {}
}
