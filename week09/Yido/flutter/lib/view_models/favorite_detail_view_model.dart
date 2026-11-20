import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/services/favorite_api_service.dart';

/// 영화 상세의 북마크 상태. 서버 성공을 확인한 뒤에만 아이콘을 바꾼다(optimistic update 없음)
class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
    this.onSessionExpired,
  });

  /// TMDB 영화 ID. 즐겨찾기 경로에는 favoriteId가 아니라 이 값을 쓴다
  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;

  /// AUTH401_2/3/4일 때 현재 세션을 한 번 정리한다(8주차 AuthViewModel.expireSession)
  final Future<void> Function()? onSessionExpired;

  bool isFavorite = false;
  bool hasLoadedStatus = false;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  ({int generation, bool ok}) _snapshot() {
    final generation = sessionGuard.generation;
    return (
      generation: generation,
      ok: sessionGuard.isCurrent(generation, accountId) && !isDisposed,
    );
  }

  /// 응답이 도착했을 때 같은 세션이고 화면이 살아 있는지 확인한다
  bool _stillCurrent(int generation) =>
      sessionGuard.isCurrent(generation, accountId) && !isDisposed;

  /// 이전 계정에서 늦게 도착한 401은 현재 계정을 로그아웃시키지 않는다
  Future<bool> _handleExpired(Object error, int generation) async {
    if (error is! DioException || !isSessionExpiredError(error)) return false;
    if (sessionGuard.isCurrent(generation, accountId)) {
      await onSessionExpired?.call();
    }
    return true;
  }

  Future<void> load() async {
    if (isLoading || isSaving) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    isLoading = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (!_stillCurrent(snap.generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } catch (error) {
      if (await _handleExpired(error, snap.generation)) return;
      if (!_stillCurrent(snap.generation)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (_stillCurrent(snap.generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  /// 등록·해제 중에는 중복 탭을 막는다. timeout이어도 같은 POST를 자동으로 다시 보내지 않는다
  Future<void> toggle() async {
    if (isSaving || isLoading || !hasLoadedStatus) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    final before = isFavorite;
    isSaving = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      if (before) {
        await favoriteApi.deleteFavorite(movieId: movieId);
      } else {
        await favoriteApi.addFavorite(movieId: movieId);
      }
      if (!_stillCurrent(snap.generation)) return;
      isFavorite = !before;
    } catch (error) {
      if (await _handleExpired(error, snap.generation)) return;
      if (!_stillCurrent(snap.generation)) return;
      final code = error is DioException ? apiErrorCode(error) : null;
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        // 이미 등록(409)이거나 이미 해제(404)이면 서버의 현재 여부로 화면을 맞춘다
        await _syncWithServer(snap.generation, before);
      } else {
        isFavorite = before;
        errorMessage = '저장하지 못했습니다. 다시 시도해 주세요.';
      }
    } finally {
      if (_stillCurrent(snap.generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }

  Future<void> _syncWithServer(int generation, bool before) async {
    try {
      final synced = await favoriteApi.checkFavorite(movieId: movieId);
      if (!_stillCurrent(generation)) return;
      isFavorite = synced.isFavorite;
      errorMessage = null;
    } catch (_) {
      if (!_stillCurrent(generation)) return;
      isFavorite = before;
      errorMessage = '서버 상태를 다시 확인하지 못했습니다.';
    }
  }
}
