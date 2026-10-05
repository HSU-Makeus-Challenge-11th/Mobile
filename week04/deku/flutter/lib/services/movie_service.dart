import '../data/mock_movies.dart';
import '../models/movie.dart';

abstract interface class MovieService {
  Future<List<Movie>> fetchMovies({required String genre});
}

enum MovieLoadMode { success, empty, failure, failureOnce }

final class MovieLoadException implements Exception {
  const MovieLoadException();
}

final class FakeMovieService implements MovieService {
  FakeMovieService({
    MovieLoadMode? mode,
    this.delay = const Duration(milliseconds: 1000),
  }) : mode = mode ?? _modeFromEnvironment();

  final MovieLoadMode mode;
  final Duration delay;

  int _requestCount = 0;

  @override
  Future<List<Movie>> fetchMovies({required String genre}) async {
    _requestCount += 1;
    await Future<void>.delayed(delay);

    if (mode == MovieLoadMode.failure ||
        (mode == MovieLoadMode.failureOnce && _requestCount == 1)) {
      throw const MovieLoadException();
    }

    if (mode == MovieLoadMode.empty) {
      return const <Movie>[];
    }

    // TODO(5주차 유저별 평점 조회 API): 실제 영화 API 구현체로 교체한다.
    if (genre == '전체') {
      return List<Movie>.unmodifiable(movies);
    }

    return List<Movie>.unmodifiable(
      movies.where((movie) => movie.genre == genre),
    );
  }

  static MovieLoadMode _modeFromEnvironment() {
    const value = String.fromEnvironment(
      'MOVIE_LOAD_MODE',
      defaultValue: 'success',
    );

    return switch (value) {
      'empty' => MovieLoadMode.empty,
      'error' => MovieLoadMode.failure,
      'retry' => MovieLoadMode.failureOnce,
      _ => MovieLoadMode.success,
    };
  }
}
