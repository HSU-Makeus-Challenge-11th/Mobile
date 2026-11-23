import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/map_bounded.dart';
import '../core/utils/safe_notify.dart';
import '../data/models/favorite_list_item.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'load_phase.dart';

/// 내 즐겨찾기 화면 ViewModel.
///
/// refresh(): 세션 확인 → GET /v8/favorites → movieId마다 TMDB 영화 정보 보충 → 상태 결정.
/// 목록 조회 전체 실패(error)와 영화 한 건의 정보 실패(item.movie == null)를 구분한다.
class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.tmdbApi,
    required this.sessionGuard,
    required this.accountId,
    this.onSessionExpired,
    this.enrichmentConcurrency = 5,
  });

  final FavoriteApiService favoriteApi;
  final TmdbMovieService tmdbApi;
  final SessionGuard sessionGuard;

  /// 화면 쪽 세션 구분에만 쓰는 email. 즐겨찾기 API에는 보내지 않는다(JWT로 구분).
  final String accountId;

  /// 만료·무효 토큰(AUTH401_2/3/4)일 때 8주차 AuthViewModel.expireSession()을 호출한다.
  final Future<void> Function()? onSessionExpired;

  /// TMDB 보충 요청을 한 번에 최대 몇 개까지 보낼지.
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];
  String? errorMessage;

  /// 영화 정보를 다시 조회 중인 카드의 movieId.
  final Set<int> retryingMovieIds = {};
  int _refreshGeneration = 0;

  bool _isStale(int sessionGeneration, int refreshGeneration) =>
      !sessionGuard.isCurrent(sessionGeneration, accountId) ||
      refreshGeneration != _refreshGeneration ||
      isDisposed;

  /// 즐겨찾기 목록을 다시 조회하고 TMDB 영화 정보를 최대 5개씩 보충한다.
  Future<void> refresh() async {
    final sessionGeneration = sessionGuard.generation;
    if (!sessionGuard.isCurrent(sessionGeneration, accountId) || isDisposed) {
      return;
    }
    final refreshGeneration = ++_refreshGeneration;
    phase = LoadPhase.loading;
    errorMessage = null;
    retryingMovieIds.clear();
    notifyIfAlive();
    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (_isStale(sessionGeneration, refreshGeneration)) return;
      // 카드별 실패를 결과로 바꿔, 한 건이 실패해도 목록 전체가 실패하지 않게 한다.
      final enriched = await mapBounded(favorites, enrichmentConcurrency, (
        favorite,
      ) async {
        try {
          final movie = await tmdbApi.fetchMovieDetail(favorite.movieId);
          return FavoriteListItem(favorite: favorite, movie: movie);
        } catch (_) {
          return FavoriteListItem(
            favorite: favorite,
            errorMessage: '영화 정보를 불러오지 못했습니다.',
          );
        }
      });
      if (_isStale(sessionGeneration, refreshGeneration)) return;
      items = enriched;
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } on DioException catch (error) {
      if (_isStale(sessionGeneration, refreshGeneration)) return;
      if (isSessionExpiredCode(apiErrorCode(error))) {
        await onSessionExpired?.call();
        return;
      }
      phase = LoadPhase.error;
      errorMessage = '내 즐겨찾기 목록을 불러오지 못했습니다.';
    } catch (_) {
      if (_isStale(sessionGeneration, refreshGeneration)) return;
      phase = LoadPhase.error;
      errorMessage = '내 즐겨찾기 목록을 불러오지 못했습니다.';
    } finally {
      if (!_isStale(sessionGeneration, refreshGeneration)) notifyIfAlive();
    }
  }

  /// 영화 정보를 가져오지 못한 카드 한 장만 TMDB에서 다시 조회한다. 다른 카드는 그대로 둔다.
  Future<void> retryMovie(int movieId) async {
    if (phase != LoadPhase.ready || retryingMovieIds.contains(movieId)) return;
    final sessionGeneration = sessionGuard.generation;
    final refreshGeneration = _refreshGeneration;
    if (_isStale(sessionGeneration, refreshGeneration)) return;
    retryingMovieIds.add(movieId);
    notifyIfAlive();
    TmdbMovieDto? movie;
    try {
      movie = await tmdbApi.fetchMovieDetail(movieId);
    } catch (_) {
      movie = null; // 실패하면 placeholder를 유지한다.
    }
    if (_isStale(sessionGeneration, refreshGeneration)) return;
    retryingMovieIds.remove(movieId);
    if (movie != null) {
      items = [
        for (final item in items)
          item.favorite.movieId == movieId
              ? FavoriteListItem(favorite: item.favorite, movie: movie)
              : item,
      ];
    }
    notifyIfAlive();
  }
}
