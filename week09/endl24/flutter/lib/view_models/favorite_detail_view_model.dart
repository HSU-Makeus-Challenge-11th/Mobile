import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/services/favorite_api_service.dart';

/// 영화 상세 화면의 즐겨찾기(북마크) 버튼 상태입니다.
///
/// 서버 성공을 확인한 뒤에만 isFavorite를 바꿉니다(optimistic update를 쓰지 않습니다).
/// 응답이 도착했을 때 세션이 바뀌었거나 화면이 닫혔으면 그 응답은 버립니다.
class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
  });

  /// TMDB 영화 ID. 즐겨찾기 경로에는 favoriteId가 아니라 이 값을 씁니다.
  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;

  /// 이 ViewModel을 만든 계정(email)입니다.
  final String accountId;

  bool isFavorite = false; // 서버에서 확인한 값
  bool hasLoadedStatus = false; // 첫 여부 조회에 성공했는지
  bool isLoading = false; // 첫 여부 조회 중
  bool isSaving = false; // 등록·해제 중
  String? errorMessage;

  /// 요청을 보내기 직전의 세션 번호입니다. 지금 세션이 아니면 null입니다.
  int? _currentGeneration() {
    final generation = sessionGuard.generation;
    if (isDisposed || !sessionGuard.isCurrent(generation, accountId)) {
      return null;
    }
    return generation;
  }

  /// 응답이 도착했을 때, 요청을 보낸 세션과 다르거나 화면이 닫혔으면 true입니다.
  bool _isStale(int generation) =>
      isDisposed || !sessionGuard.isCurrent(generation, accountId);

  /// 화면이 처음 만들어질 때 한 번, 그리고 조회 실패 뒤 새로고침 버튼으로 호출합니다.
  Future<void> load() async {
    if (isLoading || isSaving) return;
    final generation = _currentGeneration();
    if (generation == null) return;

    isLoading = true;
    errorMessage = null;
    notifyIfAlive();

    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (_isStale(generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } catch (_) {
      if (_isStale(generation)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (!_isStale(generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  /// 등록 ↔ 해제. 요청 중에는 버튼을 막아 중복 탭을 방지합니다.
  Future<void> toggle() async {
    if (isSaving || isLoading || !hasLoadedStatus) return;
    final generation = _currentGeneration();
    if (generation == null) return;

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
      if (_isStale(generation)) return;
      isFavorite = !before;
    } on DioException catch (error) {
      if (_isStale(generation)) return;
      final code = apiErrorCode(error);
      // 이미 등록(409)이거나 이미 해제(404)된 경우: 다른 기기에서 바뀐 것이므로
      // 서버의 현재 여부를 다시 조회해 화면을 맞춥니다.
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        await _syncFromServer(generation, before);
      } else {
        isFavorite = before;
        errorMessage = _failMessage(before);
      }
    } catch (_) {
      if (_isStale(generation)) return;
      isFavorite = before;
      errorMessage = _failMessage(before);
    } finally {
      if (!_isStale(generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }

  Future<void> _syncFromServer(int generation, bool before) async {
    try {
      final synced = await favoriteApi.checkFavorite(movieId: movieId);
      if (_isStale(generation)) return;
      isFavorite = synced.isFavorite;
      errorMessage = null;
    } catch (_) {
      if (_isStale(generation)) return;
      isFavorite = before;
      errorMessage = '서버 상태를 다시 확인하지 못했습니다.';
    }
  }

  String _failMessage(bool wasFavorite) =>
      wasFavorite ? '즐겨찾기 해제에 실패했습니다.' : '즐겨찾기 등록에 실패했습니다.';
}
