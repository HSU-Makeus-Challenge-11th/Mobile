import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/safe_notify.dart';
import '../data/services/favorite_api_service.dart';

/// 영화 상세 화면의 즐겨찾기(북마크) 상태.
///
/// 서버 성공을 확인한 뒤에만 북마크를 바꾼다(optimistic update를 쓰지 않는다).
/// 응답이 도착했을 때 로그인 세션이 바뀌었거나 화면이 사라졌으면 결과를 버린다.
class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
    this.onSessionExpired,
  });

  /// 상세 화면의 TMDB 영화 ID. 즐겨찾기 경로에는 favoriteId가 아니라 이 값을 쓴다.
  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;

  /// 만료·무효 토큰(AUTH401_2/3/4)을 받았을 때 8주차 AuthViewModel.expireSession()을 호출한다.
  /// 현재 세션의 응답일 때만 호출하므로, 이전 계정의 늦은 401이 현재 계정을 로그아웃시키지 않는다.
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

  bool _isStale(int generation) =>
      !sessionGuard.isCurrent(generation, accountId) || isDisposed;

  /// 서버의 즐겨찾기 여부를 조회한다. 화면 초기화 때 한 번, 실패 시 새로고침 버튼으로 다시 호출한다.
  Future<void> load() async {
    if (isLoading || isSaving) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    isLoading = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (_isStale(snap.generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } on DioException catch (error) {
      if (_isStale(snap.generation)) return;
      if (isSessionExpiredCode(apiErrorCode(error))) {
        await onSessionExpired?.call();
        return;
      }
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } catch (_) {
      if (_isStale(snap.generation)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (!_isStale(snap.generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  /// 등록·해제. 요청 중에는 중복 탭을 막고, timeout이어도 같은 POST를 자동으로 다시 보내지 않는다.
  Future<void> toggle() async {
    if (isSaving || isLoading || !hasLoadedStatus) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    final before = isFavorite;
    final failMessage = before ? '즐겨찾기 해제에 실패했습니다.' : '즐겨찾기 등록에 실패했습니다.';
    isSaving = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      if (before) {
        await favoriteApi.deleteFavorite(movieId: movieId);
        if (_isStale(snap.generation)) return;
        isFavorite = false;
      } else {
        await favoriteApi.addFavorite(movieId: movieId);
        if (_isStale(snap.generation)) return;
        isFavorite = true;
      }
    } on DioException catch (error) {
      if (_isStale(snap.generation)) return;
      final code = apiErrorCode(error);
      if (isSessionExpiredCode(code)) {
        errorMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
        await onSessionExpired?.call();
        return;
      }
      // 이미 등록(409)이거나 이미 해제(404)이면 서버의 현재 여부로 화면을 맞춘다.
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        try {
          final synced = await favoriteApi.checkFavorite(movieId: movieId);
          if (_isStale(snap.generation)) return;
          isFavorite = synced.isFavorite;
          errorMessage = null;
        } catch (_) {
          if (_isStale(snap.generation)) return;
          isFavorite = before;
          errorMessage = '서버 상태를 다시 확인하지 못했습니다.';
        }
      } else {
        // 네트워크 실패·403 등: 로그아웃하지 않고 이전 버튼 상태를 유지한다.
        isFavorite = before;
        errorMessage = failMessage;
      }
    } catch (_) {
      if (_isStale(snap.generation)) return;
      isFavorite = before;
      errorMessage = failMessage;
    } finally {
      if (!_isStale(snap.generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }
}
