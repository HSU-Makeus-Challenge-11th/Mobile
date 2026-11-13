import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_ratings.dart';

/// 이번 로그인 세션에서 등록한 평점 목록을 보여주고 수정·삭제합니다.
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._sessionRatings, this._auth) {
    _sessionRatings.addListener(_onRatingsChanged);
  }

  final RatingApiService _service;
  final SessionRatings _sessionRatings;
  final AuthViewModel _auth;
  bool _disposed = false;

  List<RatingWithMovie> get ratings => _sessionRatings.items;

  void _onRatingsChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth.sessionVersion;
    try {
      // v7 수정 result는 수정된 평점 전체라서 목록을 다시 조회하지 않고 바로 교체합니다.
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      _sessionRatings.replace(updated, sessionVersion: version);
    } on DioException catch (error) {
      await _handleWriteError(error, ratingId, version);
      rethrow; // Dialog가 서버 문구를 보여줍니다.
    }
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      _sessionRatings.remove(ratingId, sessionVersion: version);
    } on DioException catch (error) {
      await _handleWriteError(error, ratingId, version);
      rethrow;
    }
  }

  /// 401은 세션 정리, 404는 목록에서 제거, 403·409·400은 안내만 합니다(로그아웃하지 않음).
  Future<void> _handleWriteError(
    DioException error,
    int ratingId,
    int version,
  ) async {
    if (version != _auth.sessionVersion) return; // 이전 세션의 늦은 응답은 무시합니다.
    final code = apiErrorCode(error);
    if (isSessionInvalidCode(code)) {
      await _auth.expireSession();
    } else if (code == 'RATING404_1') {
      _sessionRatings.remove(ratingId, sessionVersion: version);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionRatings.removeListener(_onRatingsChanged);
    super.dispose();
  }
}
