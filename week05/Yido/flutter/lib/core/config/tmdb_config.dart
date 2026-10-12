import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class TmdbConfig {
  // .env가 로드되지 않은 테스트 환경에서도 예외 없이 빈 값을 돌려준다
  static String get accessToken => dotenv.isInitialized
      ? dotenv.env['TMDB_ACCESS_TOKEN'] ?? ''
      : '';
}
