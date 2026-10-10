import 'package:flutter/foundation.dart';
import 'package:movielog/models/tmdb_genre_dto.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/service/genre_preference.dart';
import 'package:movielog/service/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service, {GenrePreference? genrePreference})
    : _genrePreference = genrePreference ?? GenrePreference();

  static const _maxMovies = 30;

  final TmdbMovieService _service;
  final GenrePreference _genrePreference;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  String? genreNameOf(TmdbMovieDto movie) {
    for (final genre in genres) {
      if (movie.genreIds.contains(genre.id)) return genre.name;
    }
    return null;
  }

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      selectedGenreId ??= await _genrePreference.read();
      genres = await _service.fetchGenres();
      final result = await _fetchUpToThirtyMovies(genreId: selectedGenreId);

      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (error) {
      if (_disposed || version != _requestVersion) return;
      debugPrint('[MovieListViewModel] 영화 목록 로드 실패: $error');
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    }

    notifyListeners();
  }

  Future<void> selectGenre(int? genreId) async {
    if (isLoading || genreId == selectedGenreId) return;

    selectedGenreId = genreId;
    _genrePreference.save(genreId);
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await _fetchUpToThirtyMovies(genreId: genreId);

      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (error) {
      if (_disposed || version != _requestVersion) return;
      debugPrint('[MovieListViewModel] 장르 영화 로드 실패: $error');
      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
    }

    notifyListeners();
  }

  Future<List<TmdbMovieDto>> _fetchUpToThirtyMovies({int? genreId}) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < _maxMovies && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == _maxMovies) break;
      }

      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }

    return byId.values.toList();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
