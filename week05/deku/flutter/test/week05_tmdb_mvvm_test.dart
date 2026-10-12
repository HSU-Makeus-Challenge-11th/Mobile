import 'package:deku/data/models/tmdb_genre_dto.dart';
import 'package:deku/data/models/tmdb_movie_dto.dart';
import 'package:deku/data/models/tmdb_movie_page_dto.dart';
import 'package:deku/data/services/tmdb_movie_service.dart';
import 'package:deku/services/genre_preference.dart';
import 'package:deku/view_models/movie_home_view_model.dart';
import 'package:deku/view_models/movie_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TMDB 영화 JSON의 null과 num 타입을 안전하게 변환한다', () {
    final movie = TmdbMovieDto.fromJson({
      'id': 10.0,
      'title': '테스트 영화',
      'overview': null,
      'poster_path': null,
      'genre_ids': [18.0, '878'],
      'release_date': '',
      'vote_average': 7,
      'vote_count': 12.0,
    });

    expect(movie.id, 10);
    expect(movie.genreIds, [18, 878]);
    expect(movie.posterPath, isNull);
    expect(movie.releaseYear, isNull);
    expect(movie.voteAverage, 7.0);
    expect(movie.synopsis, '줄거리 정보가 없어요.');
  });

  test('홈 ViewModel은 Popular 결과에서 최대 5개만 보관한다', () async {
    final service = _PagedMovieService();
    final viewModel = MovieHomeViewModel(service);

    await viewModel.load();

    expect(viewModel.status, MovieHomeLoadStatus.success);
    expect(viewModel.movies, hasLength(5));
    expect(service.popularRequestCount, 1);
  });

  test('목록 ViewModel은 중복을 제거해 최대 30개를 만들고 장르로 재요청한다', () async {
    final service = _PagedMovieService();
    final preference = _MemoryGenrePreference();
    final viewModel = MovieListViewModel(service, preference);

    await viewModel.load();

    expect(viewModel.status, MovieListLoadStatus.success);
    expect(viewModel.movies, hasLength(30));
    expect(viewModel.movies.map((movie) => movie.id).toSet(), hasLength(30));
    expect(service.discoverRequests, [
      (page: 1, genreId: null),
      (page: 2, genreId: null),
    ]);

    service.discoverRequests.clear();
    await viewModel.selectGenre(18);

    expect(viewModel.selectedGenreId, 18);
    expect(preference.genreId, 18);
    expect(service.discoverRequests, [
      (page: 1, genreId: 18),
      (page: 2, genreId: 18),
    ]);
  });
}

final class _PagedMovieService implements MovieService {
  int popularRequestCount = 0;
  final List<({int page, int? genreId})> discoverRequests = [];

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    popularRequestCount += 1;
    return TmdbMoviePageDto(
      page: page,
      totalPages: 1,
      results: List.generate(8, (index) => _movie(index + 1)),
    );
  }

  @override
  Future<TmdbMoviePageDto> discoverMovies({int page = 1, int? genreId}) async {
    discoverRequests.add((page: page, genreId: genreId));
    final ids = page == 1
        ? List.generate(20, (index) => index + 1)
        : List.generate(26, (index) => index + 15);
    return TmdbMoviePageDto(
      page: page,
      totalPages: 2,
      results: ids.map(_movie).toList(growable: false),
    );
  }

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async {
    return const [TmdbGenreDto(id: 18, name: '드라마')];
  }

  TmdbMovieDto _movie(int id) => TmdbMovieDto(
    id: id,
    title: '영화 $id',
    genreIds: const [18],
    releaseDate: '2026-01-01',
  );
}

final class _MemoryGenrePreference implements GenrePreferenceStore {
  int? genreId;

  @override
  Future<int?> read() async => genreId;

  @override
  Future<void> save(int? genreId) async {
    this.genreId = genreId;
  }
}
