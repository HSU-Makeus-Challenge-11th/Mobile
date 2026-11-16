import 'package:dio/dio.dart';

import '../config/movie_log_config.dart';

Dio createMovieLogClient() {
  return Dio(
    BaseOptions(
      baseUrl: MovieLogConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'accept': 'application/json'},
    ),
  );
}
