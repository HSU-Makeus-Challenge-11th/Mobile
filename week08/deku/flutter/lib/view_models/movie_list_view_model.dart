import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../services/genre_preference.dart';

enum MovieListLoadStatus { idle, loading, empty, error, success }

final class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service, this._preferenceStore);

  final MovieService _service;
  final GenrePreferenceStore _preferenceStore;

  bool _disposed = false;
  int _requestId = 0;

  MovieListLoadStatus status = MovieListLoadStatus.idle;
  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  Object? error;

  bool get isLoading => status == MovieListLoadStatus.loading;

  Future<void> load() async {
    if (isLoading) return;

    final requestId = ++_requestId;
    _setLoading();

    try {
      final savedGenreId = await _preferenceStore.read();
      final loadedGenres = await _service.fetchGenres();
      if (!_isCurrent(requestId)) return;

      genres = loadedGenres;
      selectedGenreId = loadedGenres.any((genre) => genre.id == savedGenreId)
          ? savedGenreId
          : null;
      final loadedMovies = await _fetchUpToThirty(selectedGenreId);
      if (!_isCurrent(requestId)) return;

      movies = _attachGenreNames(loadedMovies);
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
      _notify();
    } catch (caught) {
      _setError(requestId, caught);
    }
  }

  Future<void> selectGenre(int? genreId) async {
    if (isLoading || genreId == selectedGenreId) return;

    selectedGenreId = genreId;
    try {
      await _preferenceStore.save(genreId);
    } catch (_) {
      // 선택 저장 실패는 영화 조회 자체를 막지 않습니다.
    }
    await _loadMovies(genreId);
  }

  Future<void> retry() async {
    if (genres.isEmpty) {
      await load();
      return;
    }
    await _loadMovies(selectedGenreId);
  }

  Future<void> _loadMovies(int? genreId) async {
    final requestId = ++_requestId;
    _setLoading();

    try {
      final loadedMovies = await _fetchUpToThirty(genreId);
      if (!_isCurrent(requestId)) return;

      movies = _attachGenreNames(loadedMovies);
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
      _notify();
    } catch (caught) {
      _setError(requestId, caught);
    }
  }

  Future<List<TmdbMovieDto>> _fetchUpToThirty(int? genreId) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == 30) break;
      }

      hasNextPage = page.results.isNotEmpty && pageNumber < page.totalPages;
      pageNumber += 1;
    }

    return byId.values.take(30).toList(growable: false);
  }

  List<TmdbMovieDto> _attachGenreNames(List<TmdbMovieDto> source) {
    final namesById = {for (final genre in genres) genre.id: genre.name};
    return source
        .map(
          (movie) => movie.copyWith(
            genreNames: movie.genreIds
                .map((id) => namesById[id])
                .whereType<String>()
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  void _setLoading() {
    status = MovieListLoadStatus.loading;
    error = null;
    _notify();
  }

  void _setError(int requestId, Object caught) {
    if (!_isCurrent(requestId)) return;
    error = caught;
    movies = const [];
    status = MovieListLoadStatus.error;
    _notify();
  }

  bool _isCurrent(int requestId) => !_disposed && requestId == _requestId;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId += 1;
    super.dispose();
  }
}
