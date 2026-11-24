import 'package:flutter/foundation.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/map_bounded.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/models/favorite_list_item.dart';
import 'package:movielog/data/models/favorite_response_dto.dart';
import 'package:movielog/data/services/favorite_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/load_phase.dart';

/// 내 즐겨찾기 화면의 상태입니다.
///
/// 1. GET /v8/favorites로 즐겨찾기 목록(movieId)을 받습니다.
/// 2. 제목·포스터가 없으므로 movieId로 TMDB 영화 정보를 최대 5개씩 동시에 보충합니다.
/// 3. 영화 정보 한 건이 실패해도 그 카드만 placeholder로 두고 나머지는 보여 줍니다.
class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.tmdbApi,
    required this.sessionGuard,
    required this.accountId,
    this.enrichmentConcurrency = 5,
  });

  final FavoriteApiService favoriteApi;
  final TmdbMovieService tmdbApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];

  /// 목록 조회 실패 문구입니다. 이미 목록이 있으면 목록은 그대로 두고 이 문구만 보여 줍니다.
  String? errorMessage;

  /// 영화 정보를 다시 가져오는 중인 favoriteId 목록입니다.
  final Set<int> retryingIds = {};

  /// refresh를 여러 번 눌렀을 때 마지막 요청의 응답만 반영하기 위한 번호입니다.
  int _refreshGeneration = 0;

  /// 요청을 보낸 세션이 끝났거나 화면이 닫혔으면 true입니다.
  bool _sessionEnded(int sessionGeneration) =>
      isDisposed || !sessionGuard.isCurrent(sessionGeneration, accountId);

  /// 즐겨찾기 목록을 다시 조회합니다. 처음 진입, 당겨서 새로고침, 상세에서 돌아왔을 때 호출합니다.
  Future<void> refresh() async {
    final sessionGeneration = sessionGuard.generation;
    if (_sessionEnded(sessionGeneration)) return;
    final refreshGeneration = ++_refreshGeneration;
    bool isStale() =>
        _sessionEnded(sessionGeneration) ||
        refreshGeneration != _refreshGeneration;

    // 이미 보여 주는 목록이 있으면 지우지 않고 뒤에서 다시 조회합니다.
    if (items.isEmpty) phase = LoadPhase.loading;
    errorMessage = null;
    notifyIfAlive();

    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (isStale()) return;

      final enriched = await mapBounded(
        favorites,
        enrichmentConcurrency,
        _withMovie,
      );
      if (isStale()) return;

      items = enriched;
      retryingIds.clear();
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (_) {
      if (isStale()) return;
      errorMessage = '내 즐겨찾기 목록을 불러오지 못했습니다.';
      if (items.isEmpty) phase = LoadPhase.error;
    } finally {
      if (!isStale()) notifyIfAlive();
    }
  }

  /// 영화 정보를 가져오지 못한 카드 한 장만 다시 조회합니다. 다른 카드는 그대로 둡니다.
  Future<void> retryMovie(int favoriteId) async {
    if (retryingIds.contains(favoriteId)) return;
    final sessionGeneration = sessionGuard.generation;
    if (_sessionEnded(sessionGeneration)) return;
    final index = items.indexWhere((i) => i.favorite.favoriteId == favoriteId);
    if (index < 0) return;

    final refreshGeneration = _refreshGeneration;
    retryingIds.add(favoriteId);
    notifyIfAlive();

    final updated = await _withMovie(items[index].favorite);
    // 그 사이 목록 전체를 다시 불러왔다면 새 목록을 우선합니다.
    if (_sessionEnded(sessionGeneration) ||
        refreshGeneration != _refreshGeneration) {
      return;
    }
    retryingIds.remove(favoriteId);
    items = [
      for (final item in items)
        item.favorite.favoriteId == favoriteId ? updated : item,
    ];
    notifyIfAlive();
  }

  /// 즐겨찾기 하나에 TMDB 영화 정보를 붙입니다. 실패해도 예외 대신 placeholder 카드를 돌려줍니다.
  Future<FavoriteListItem> _withMovie(FavoriteResponseDto favorite) async {
    try {
      final movie = await tmdbApi.fetchMovieDetail(favorite.movieId);
      return FavoriteListItem(favorite: favorite, movie: movie);
    } catch (_) {
      return FavoriteListItem(
        favorite: favorite,
        errorMessage: '영화 정보를 불러오지 못했습니다.',
      );
    }
  }
}
