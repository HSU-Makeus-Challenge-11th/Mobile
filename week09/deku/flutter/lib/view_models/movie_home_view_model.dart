import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, empty, error, success }

final class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final MovieService _service;
  bool _disposed = false;

  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  List<TmdbMovieDto> movies = const [];
  Object? error;

  Future<void> load({bool force = false}) async {
    if (status == MovieHomeLoadStatus.loading) return;
    if (!force && status != MovieHomeLoadStatus.idle) return;

    status = MovieHomeLoadStatus.loading;
    error = null;
    _notify();

    try {
      final page = await _service.fetchPopular();
      movies = page.results.take(5).toList(growable: false);
      status = movies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } catch (caught) {
      error = caught;
      status = MovieHomeLoadStatus.error;
    }
    _notify();
  }

  Future<void> retry() => load(force: true);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
