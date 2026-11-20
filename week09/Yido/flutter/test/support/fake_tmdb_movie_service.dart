import 'package:dio/dio.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

TmdbMovieDto fakeMovie(
  int id, {
  String? title,
  List<int> genreIds = const [878],
}) => TmdbMovieDto(
  id: id,
  title: title ?? '영화 $id',
  overview: '',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2024-01-01',
  genreIds: genreIds,
  voteAverage: 8,
  popularity: 1,
);

/// 실제 TMDB 대신 정해 둔 페이지를 돌려주고, 요청 기록을 남긴다
class FakeTmdbMovieService extends TmdbMovieService {
  FakeTmdbMovieService({
    this.popular = const [],
    Map<int?, List<List<TmdbMovieDto>>>? discoverPages,
    this.fail = false,
    this.detailMovies = const {},
  }) : discoverPages = discoverPages ?? {},
       super(Dio());

  final List<TmdbMovieDto> popular;
  final Map<int?, List<List<TmdbMovieDto>>> discoverPages;
  bool fail;

  /// 상세 조회 결과. 없는 id는 null(TMDB 404)로 답한다
  final Map<int, TmdbMovieDto> detailMovies;
  final detailCalls = <int>[];

  /// 여기 있는 id는 네트워크 실패로 답한다
  final failingDetailIds = <int>{};
  final discoverCalls = <({int page, int? genreId})>[];

  static const genres = [
    TmdbGenreDto(id: 28, name: '액션'),
    TmdbGenreDto(id: 878, name: 'SF'),
  ];

  DioException _error(String path) =>
      DioException(requestOptions: RequestOptions(path: path));

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    if (fail) throw _error('/movie/popular');
    return TmdbMoviePageDto(
      page: 1,
      results: popular,
      totalPages: 1,
      totalResults: popular.length,
    );
  }

  @override
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    int? genreId,
  }) async {
    discoverCalls.add((page: page, genreId: genreId));
    if (fail) throw _error('/discover/movie');
    final pages = discoverPages[genreId] ?? const [];
    return TmdbMoviePageDto(
      page: page,
      results: page <= pages.length ? pages[page - 1] : const [],
      totalPages: pages.length,
      totalResults: pages.fold(0, (sum, p) => sum + p.length),
    );
  }

  @override
  Future<TmdbMovieDto?> findMovieById(int movieId) async {
    detailCalls.add(movieId);
    if (failingDetailIds.contains(movieId)) throw _error('/movie/$movieId');
    return detailMovies[movieId];
  }

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async {
    if (fail) throw _error('/genre/movie/list');
    return genres;
  }
}
