import 'package:ble_project/base/http/http_transformer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../dio_new.dart';
import 'app_dio.dart';
import 'http_response.dart';
import 'http_config.dart';
import 'http_parse.dart';

class HttpClient {
  late AppDio _dio;

  HttpClient({BaseOptions? options, HttpConfig? dioConfig})
    : _dio = AppDio(options: options, dioConfig: dioConfig);

  Future<HttpResponse> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    HttpTransformer? httpTransformer,
  }) async {
    Future<Response<dynamic>> request() => _dio.get<dynamic>(
      uri,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    try {
      var response = await request();
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      if (kIsWeb && _isRetryableWebGetError(e)) {
        try {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          var response = await request();
          return handleResponse(response, httpTransformer: httpTransformer);
        } on Exception catch (retryError) {
          return handleException(retryError);
        }
      }
      return handleException(e);
    }
  }

  bool _isRetryableWebGetError(Exception error) {
    if (error is! DioException) return false;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.unknown;
  }

  Future<HttpResponse> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      var response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<HttpResponse> patch(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      var response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<HttpResponse> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      var response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<HttpResponse> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      var response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<Response> download(
    String urlPath,
    savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options? options,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      var response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}
