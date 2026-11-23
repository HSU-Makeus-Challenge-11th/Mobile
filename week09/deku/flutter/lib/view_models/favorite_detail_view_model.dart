import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/auth_interceptor.dart';
import '../data/services/favorite_api_service.dart';
import 'auth_view_model.dart';

final class FavoriteDetailViewModel extends ChangeNotifier {
  FavoriteDetailViewModel(this._api, this._auth, this.movieId)
    : _sessionVersion = _auth.sessionVersion {
    _auth.addListener(_onAuthChanged);
  }

  final FavoriteApiService _api;
  final AuthViewModel _auth;
  final int movieId;
  final int _sessionVersion;
  bool _disposed = false;
  int _generation = 0;

  bool isFavorite = false;
  bool stateKnown = false;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  bool get _active => !_disposed && _auth.isCurrentSession(_sessionVersion);

  Future<void> load() async {
    final generation = ++_generation;
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      final result = await _api.isFavorite(movieId);
      if (!_active || generation != _generation) return;
      isFavorite = result;
      stateKnown = true;
    } catch (_) {
      if (!_active || generation != _generation) return;
      errorMessage = '즐겨찾기 상태를 확인하지 못했어요.';
    } finally {
      if (_active && generation == _generation) {
        isLoading = false;
        _notify();
      }
    }
  }

  Future<String?> toggle() async {
    if (!_active || !stateKnown || isLoading || isSaving) return null;
    final wasFavorite = isFavorite;
    final generation = ++_generation;
    isSaving = true;
    errorMessage = null;
    _notify();
    try {
      if (wasFavorite) {
        await _api.removeFavorite(movieId);
      } else {
        await _api.addFavorite(movieId);
      }
      if (!_active || generation != _generation) return null;
      isFavorite = !wasFavorite;
      return isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.';
    } on DioException catch (error) {
      if (!_active || generation != _generation) return null;
      final code = apiErrorCode(error);
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        try {
          isFavorite = await _api.isFavorite(movieId);
          if (!_active || generation != _generation) return null;
          return isFavorite ? '이미 즐겨찾기에 등록되어 있어요.' : '이미 즐겨찾기에서 해제되었어요.';
        } catch (_) {
          if (!_active || generation != _generation) return null;
        }
      }
      errorMessage = '즐겨찾기를 변경하지 못했어요. 다시 확인해 주세요.';
      return errorMessage;
    } catch (_) {
      if (!_active || generation != _generation) return null;
      errorMessage = '즐겨찾기를 변경하지 못했어요. 다시 확인해 주세요.';
      return errorMessage;
    } finally {
      if (_active && generation == _generation) {
        isSaving = false;
        _notify();
      }
    }
  }

  void _onAuthChanged() {
    if (_active) return;
    _generation++;
    isFavorite = false;
    stateKnown = false;
    isLoading = false;
    isSaving = false;
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
