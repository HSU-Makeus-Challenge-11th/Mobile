import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class MovieLogConfig {
  static const defaultApiBaseUrl = 'https://workbook.devnoco.com';

  static String get apiBaseUrl {
    if (!dotenv.isInitialized) return defaultApiBaseUrl;
    final configured = dotenv.env['MOVIE_LOG_BASE_URL']?.trim() ?? '';
    final base = configured.isEmpty ? defaultApiBaseUrl : configured;
    return base.replaceFirst(RegExp(r'/v[0-9]+/?$'), '');
  }
}
