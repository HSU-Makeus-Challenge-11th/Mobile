import 'package:flutter/foundation.dart';

import '../core/async/map_bounded.dart';
import '../data/models/favorite.dart';
import '../data/models/favorite_list_item.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';

enum FavoritesStatus { loading, empty, error, success }

final class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel(this._favorites, this._movies, this._auth)
    : _sessionVersion = _auth.sessionVersion {
    _auth.addListener(_onAuthChanged);
  }

  final FavoriteApiService _favorites;
  final MovieService _movies;
  final AuthViewModel _auth;
  final int _sessionVersion;
  bool _disposed = false;
  int _generation = 0;

  FavoritesStatus status = FavoritesStatus.loading;
  List<FavoriteListItem> items = const [];
  final Set<int> retryingMovieIds = {};

  bool get _active => !_disposed && _auth.isCurrentSession(_sessionVersion);

  Future<void> refresh() async {
    if (!_active) {
      _clear();
      return;
    }
    final generation = ++_generation;
    status = FavoritesStatus.loading;
    items = const [];
    retryingMovieIds.clear();
    _notify();
    try {
      final favorites = await _favorites.fetchFavorites();
      if (!_active || generation != _generation) return;
      if (favorites.isEmpty) {
        status = FavoritesStatus.empty;
        _notify();
        return;
      }
      final unique = <int, Favorite>{
        for (final favorite in favorites) favorite.movieId: favorite,
      }.values.toList(growable: false);
      final loaded = await mapBounded<Favorite, FavoriteListItem>(unique, (
        favorite,
      ) async {
        TmdbMovieDto? movie;
        try {
          movie = await _movies.fetchMovieById(favorite.movieId);
        } catch (_) {
          // One unavailable TMDB movie leaves only that card in retry state.
        }
        return FavoriteListItem(favorite: favorite, movie: movie);
      });
      if (!_active || generation != _generation) return;
      items = loaded;
      status = FavoritesStatus.success;
      _notify();
    } catch (_) {
      if (!_active || generation != _generation) return;
      status = FavoritesStatus.error;
      _notify();
    }
  }

  Future<void> retryMovie(int movieId) async {
    if (!_active || !retryingMovieIds.add(movieId)) return;
    final generation = _generation;
    _notify();
    try {
      final movie = await _movies.fetchMovieById(movieId);
      if (!_active || generation != _generation) return;
      items = [
        for (final item in items)
          item.favorite.movieId == movieId
              ? FavoriteListItem(favorite: item.favorite, movie: movie)
              : item,
      ];
    } catch (_) {
      // Keep the failed card visible for another retry.
    } finally {
      retryingMovieIds.remove(movieId);
      if (_active && generation == _generation) _notify();
    }
  }

  void _onAuthChanged() {
    if (!_active) _clear();
  }

  void _clear() {
    _generation++;
    items = const [];
    retryingMovieIds.clear();
    status = FavoritesStatus.empty;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
