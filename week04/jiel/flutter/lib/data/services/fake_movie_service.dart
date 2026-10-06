import '../mock/movie.dart';

/// FakeMovieService가 돌려줄 결과 종류. 화면의 각 상태를 확인할 때 쓴다.
enum MovieLoadMode { success, empty, failure }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;
}

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // TODO(5주차 유저별 평점 조회 API): Fake 데이터를 실제 API 호출로 교체
    await Future<void>.delayed(const Duration(seconds: 1));

    return switch (mode) {
      MovieLoadMode.success => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오지 못했습니다.'),
    };
  }
}
