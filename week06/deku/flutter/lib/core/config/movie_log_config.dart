import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class MovieLogConfig {
  static const defaultApiBaseUrl = 'https://workbook.devnoco.com/v5';

  static String get apiBaseUrl {
    if (!dotenv.isInitialized) return defaultApiBaseUrl;
    final configured = dotenv.env['MOVIE_LOG_BASE_URL']?.trim() ?? '';
    return configured.isEmpty ? defaultApiBaseUrl : configured;
  }
}
