import '../data/mock_movies.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/models/tmdb_movie_page_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieLoadMode { success, empty, failure, failureOnce }

final class MovieLoadException implements Exception {
  const MovieLoadException();
}

/// 네트워크 없이 ViewModel과 Widget 상태를 검증하기 위한 테스트 전용 Service입니다.
final class FakeMovieService implements MovieService {
  FakeMovieService({
    MovieLoadMode? mode,
    this.delay = const Duration(milliseconds: 1000),
  }) : mode = mode ?? MovieLoadMode.success;

  final MovieLoadMode mode;
  final Duration delay;
  int _requestCount = 0;

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    await _waitAndMaybeFail();
    final results = mode == MovieLoadMode.empty
        ? const <TmdbMovieDto>[]
        : movies.take(5).toList(growable: false);
    return TmdbMoviePageDto(page: page, totalPages: 1, results: results);
  }

  @override
  Future<TmdbMoviePageDto> discoverMovies({int page = 1, int? genreId}) async {
    await _waitAndMaybeFail();
    final results = mode == MovieLoadMode.empty
        ? const <TmdbMovieDto>[]
        : movies
              .where(
                (movie) => genreId == null || movie.genreIds.contains(genreId),
              )
              .toList(growable: false);
    return TmdbMoviePageDto(page: page, totalPages: 1, results: results);
  }

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async {
    return const [
      TmdbGenreDto(id: 18, name: '드라마'),
      TmdbGenreDto(id: 878, name: 'SF'),
      TmdbGenreDto(id: 16, name: '애니메이션'),
      TmdbGenreDto(id: 53, name: '스릴러'),
      TmdbGenreDto(id: 10749, name: '로맨스'),
    ];
  }

  Future<void> _waitAndMaybeFail() async {
    _requestCount += 1;
    await Future<void>.delayed(delay);
    if (mode == MovieLoadMode.failure ||
        (mode == MovieLoadMode.failureOnce && _requestCount == 1)) {
      throw const MovieLoadException();
    }
  }
}
