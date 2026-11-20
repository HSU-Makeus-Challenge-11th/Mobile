import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:movielog/view_models/submit_status.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._store,
    this._auth,
    this.movieId,
  );
  final RatingApiService _ratingService;
  final SessionRatingStore _store;
  final AuthViewModel _auth;

  /// 영화 배열 index가 아니라 TMDB 영화 id다
  final int movieId;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  bool get signedIn => _auth.status == AuthStatus.signedIn;

  Future<void> createRating({required int score, String? comment}) async {
    if (!signedIn) {
      submitStatus = SubmitStatus.error;
      submitMessage = '로그인 후 평점을 남길 수 있어요.';
      notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return;
    final version = _store.version;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      final created = await _ratingService.createRating(
        CreateRatingRequest(movieId: movieId, score: score, comment: comment),
      );
      // 등록 result의 Rating으로 현재 세션 목록을 갱신한다
      _store.put(created, version: version);
      if (_disposed) return;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (isSessionExpiredError(error) && version == _store.version) {
        await _auth.expireSession(); // 세션 정리 후 Router가 /login으로 보낸다
      }
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(error);
    } on StateError {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = '등록 결과를 확인하지 못했습니다.';
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
