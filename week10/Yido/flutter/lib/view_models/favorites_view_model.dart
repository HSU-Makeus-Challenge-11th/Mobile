import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/map_bounded.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/models/favorite_list_item.dart';
import 'package:movielog/data/services/favorite_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/load_phase.dart';

/// 내 즐겨찾기 목록. 즐겨찾기 응답에 제목·포스터가 없어 movieId로 TMDB 정보를 보충한다
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
  final String accountId;
  final Future<void> Function()? onSessionExpired;
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];
  String? errorMessage;
  int _refreshGeneration = 0;

  bool _isCurrent(int sessionGeneration, int refreshGeneration) =>
      sessionGuard.isCurrent(sessionGeneration, accountId) &&
      refreshGeneration == _refreshGeneration &&
      !isDisposed;

  Future<FavoriteListItem> _enrich(FavoriteListItem base) async {
    try {
      final movie = await tmdbApi.fetchMovieDetail(base.favorite.movieId);
      return FavoriteListItem(favorite: base.favorite, movie: movie);
    } catch (_) {
      // 한 건이 실패해도 목록 전체를 비우지 않고 그 카드만 표시한다
      return FavoriteListItem(
        favorite: base.favorite,
        errorMessage: '영화 정보를 불러오지 못했습니다.',
      );
    }
  }

  /// 세션 확인 → 목록 조회 → 영화 정보 보충(최대 5개씩) → 상태 결정
  Future<void> refresh() async {
    final sessionGeneration = sessionGuard.generation;
    if (!sessionGuard.isCurrent(sessionGeneration, accountId) || isDisposed) {
      return;
    }
    final refreshGeneration = ++_refreshGeneration;
    // 상세에서 돌아와 다시 조회할 때는 기존 카드를 지우지 않는다
    if (items.isEmpty) phase = LoadPhase.loading;
    errorMessage = null;
    notifyIfAlive();
    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
      final enriched = await mapBounded(
        favorites.map((favorite) => FavoriteListItem(favorite: favorite)),
        enrichmentConcurrency,
        _enrich,
      );
      if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
      items = enriched;
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (error) {
      if (error is DioException &&
          isSessionExpiredError(error) &&
          sessionGuard.isCurrent(sessionGeneration, accountId)) {
        await onSessionExpired?.call();
        return;
      }
      if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
      items = const [];
      phase = LoadPhase.error;
      errorMessage = '즐겨찾기를 불러오지 못했습니다.';
    } finally {
      if (_isCurrent(sessionGeneration, refreshGeneration)) notifyIfAlive();
    }
  }

  /// 영화 정보 조회에 실패한 카드 하나만 다시 조회한다
  Future<void> retryMovie(int movieId) async {
    final index = items.indexWhere((item) => item.favorite.movieId == movieId);
    if (index < 0 || items[index].hasMovie || items[index].isRetrying) return;
    final sessionGeneration = sessionGuard.generation;
    final refreshGeneration = _refreshGeneration;
    if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
    final favorite = items[index].favorite;
    items = [...items]
      ..[index] = FavoriteListItem(favorite: favorite, isRetrying: true);
    notifyIfAlive();
    final result = await _enrich(FavoriteListItem(favorite: favorite));
    if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
    final current = items.indexWhere(
      (item) => item.favorite.favoriteId == favorite.favoriteId,
    );
    if (current < 0) return;
    items = [...items]..[current] = result;
    notifyIfAlive();
  }
}
