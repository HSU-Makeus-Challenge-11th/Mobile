import 'package:movielog/models/movie.dart';

enum MovieLoadMode { success, empty, failure, timeout }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;
}

class FakeMovieService {
  const FakeMovieService();

  // TODO(5주차 유저별 평점 조회 API): 실제 API Service로 교체
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    final delay = mode == MovieLoadMode.timeout
        ? const Duration(seconds: 10)
        : const Duration(seconds: 1);
    await Future<void>.delayed(delay);

    return switch (mode) {
      MovieLoadMode.success || MovieLoadMode.timeout => mockMovies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}