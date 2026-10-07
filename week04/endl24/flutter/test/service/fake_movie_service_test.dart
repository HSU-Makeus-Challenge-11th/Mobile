import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/service/fake_movie_service.dart';

void main() {
  const service = FakeMovieService();

  group('FakeMovieService.fetchMovies', () {
    test('success 모드는 영화 목록을 반환한다', () async {
      final movies = await service.fetchMovies(mode: MovieLoadMode.success);

      expect(movies, isNotEmpty);
      expect(movies, mockMovies);
    });

    test('empty 모드는 빈 목록을 반환한다', () async {
      final movies = await service.fetchMovies(mode: MovieLoadMode.empty);

      expect(movies, isEmpty);
    });

    test('failure 모드는 MovieLoadException을 던진다', () {
      expect(
        service.fetchMovies(mode: MovieLoadMode.failure),
        throwsA(isA<MovieLoadException>()),
      );
    });

    test('기본 모드는 success다', () async {
      final movies = await service.fetchMovies();

      expect(movies, mockMovies);
    });
  });
}