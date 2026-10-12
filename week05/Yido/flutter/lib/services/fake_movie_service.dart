import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';

enum MovieLoadMode { success, empty, failure }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);
  final String message;
  @override
  String toString() => 'MovieLoadException: $message';
}

/// 실제 API 대신 지연된 Future로 영화 목록을 돌려주는 Mock Service
class FakeMovieService {
  const FakeMovieService();

  // TODO(5주차 유저별 평점 조회 API): Swagger 명세의 실제 API Service로 교체
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return switch (mode) {
      MovieLoadMode.success => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}
