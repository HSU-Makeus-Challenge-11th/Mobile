import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class TmdbConfig {
  static const apiBaseUrl = 'https://api.themoviedb.org/3';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static String get accessToken {
    final token = dotenv.env['TMDB_ACCESS_TOKEN']?.trim() ?? '';
    if (token.isEmpty) {
      throw StateError(
        'TMDB_ACCESS_TOKEN이 비어 있습니다. 프로젝트 루트의 .env 파일을 확인해 주세요.',
      );
    }
    return token;
  }
}
