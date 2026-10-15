import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/tmdb_config.dart';
import 'tmdb_logging_interceptor.dart';

Dio createTmdbClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: TmdbConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.accessToken}',
        'accept': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(TmdbLoggingInterceptor());
  }
  return dio;
}
