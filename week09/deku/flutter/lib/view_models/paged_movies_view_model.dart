import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/models/tmdb_movie_page_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum PageLoadStatus { idle, initialLoading, empty, error, success }

enum MoviePageMode { discover, search }

class PagedMoviesViewModel extends ChangeNotifier {
  PagedMoviesViewModel(this.service, {this.mode = MoviePageMode.discover});

  final MovieService service;
  final MoviePageMode mode;
  bool _disposed = false;
  int _generation = 0;

  PageLoadStatus status = PageLoadStatus.idle;
  List<TmdbMovieDto> movies = const [];
  int? selectedGenreId;
  String query = '';
  int nextPage = 1;
  bool hasMore = false;
  bool isLoadingMore = false;
  bool loadMoreFailed = false;

  bool get isInitialLoading => status == PageLoadStatus.initialLoading;

  Future<void> selectGenre(int? genreId) async {
    selectedGenreId = genreId;
    await loadFirst();
  }

  Future<void> submitSearch(String value) async {
    query = value.trim();
    if (query.isEmpty) {
      _generation++;
      movies = const [];
      status = PageLoadStatus.idle;
      hasMore = false;
      isLoadingMore = false;
      loadMoreFailed = false;
      notifySafely();
      return;
    }
    await loadFirst();
  }

  Future<void> loadFirst() async {
    final generation = ++_generation;
    movies = const [];
    nextPage = 1;
    hasMore = false;
    isLoadingMore = false;
    loadMoreFailed = false;
    status = PageLoadStatus.initialLoading;
    notifySafely();
    try {
      final page = await _fetch(1);
      if (!_isCurrent(generation)) return;
      movies = decorate(page.results);
      nextPage = page.page + 1;
      hasMore = page.results.isNotEmpty && page.page < page.totalPages;
      status = movies.isEmpty ? PageLoadStatus.empty : PageLoadStatus.success;
      notifySafely();
    } catch (_) {
      if (!_isCurrent(generation)) return;
      status = PageLoadStatus.error;
      notifySafely();
    }
  }

  Future<void> loadMore() async {
    if (status != PageLoadStatus.success || !hasMore || isLoadingMore) return;
    final generation = _generation;
    final requestedPage = nextPage;
    isLoadingMore = true;
    loadMoreFailed = false;
    notifySafely();
    try {
      final page = await _fetch(requestedPage);
      if (!_isCurrent(generation)) return;
      final byId = <int, TmdbMovieDto>{
        for (final movie in movies) movie.id: movie,
      };
      for (final movie in decorate(page.results)) {
        byId[movie.id] = movie;
      }
      movies = byId.values.toList(growable: false);
      nextPage = requestedPage + 1;
      hasMore = page.results.isNotEmpty && requestedPage < page.totalPages;
    } catch (_) {
      if (!_isCurrent(generation)) return;
      loadMoreFailed = true;
    } finally {
      if (_isCurrent(generation)) {
        isLoadingMore = false;
        notifySafely();
      }
    }
  }

  Future<void> retryFirst() => loadFirst();

  List<TmdbMovieDto> decorate(List<TmdbMovieDto> source) => source;

  Future<TmdbMoviePageDto> _fetch(int page) => mode == MoviePageMode.search
      ? service.searchMovies(query, page: page)
      : service.discoverMovies(page: page, genreId: selectedGenreId);

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void notifySafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
