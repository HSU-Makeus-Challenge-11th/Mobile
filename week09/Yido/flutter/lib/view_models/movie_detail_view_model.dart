import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/movie_record_models.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/movie_record_api_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:movielog/view_models/submit_status.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._store,
    this._auth,
    this.movieId, {
    this.movieRecordApi,
  });
  final RatingApiService _ratingService;
  final SessionRatingStore _store;
  final AuthViewModel _auth;
  final MovieRecordApiService? movieRecordApi;

  /// Dialog를 닫고 Snackbar로 알려야 하는 오류(이미 평점·이미 즐겨찾기·회원 없음)
  static const closingErrorCodes = {
    'RATING409_1',
    'FAVORITE409_1',
    'MEMBER404_1',
  };

  /// 영화 배열 index가 아니라 TMDB 영화 id다
  final int movieId;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;

  /// true면 Dialog를 닫고 Snackbar로 안내한다. false면 Dialog 안에 이유를 보여 준다
  bool closeDialogOnError = false;
  bool _disposed = false;

  bool get signedIn => _auth.status == AuthStatus.signedIn;

  Future<void> createRating({required int score, String? comment}) =>
      saveRating(score: score, comment: comment);

  /// Challenge C: 아직 즐겨찾기하지 않은 영화는 /v8/movie-records로 평점과 즐겨찾기를
  /// 한 번에 저장하고, 이미 즐겨찾기한 영화는 기존 평점 등록 API를 쓴다
  Future<void> saveRating({
    required int score,
    String? comment,
    bool viaMovieRecord = false,
    bool addToFavorites = false,
  }) async {
    if (!signedIn) {
      submitStatus = SubmitStatus.error;
      submitMessage = '로그인 후 평점을 남길 수 있어요.';
      closeDialogOnError = false;
      notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return;
    final version = _store.version;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    closeDialogOnError = false;
    notifyListeners();

    try {
      final RatingDto created;
      final recordApi = movieRecordApi;
      if (viaMovieRecord && recordApi != null) {
        final record = await recordApi.createMovieRecord(
          CreateMovieRecordRequest(
            movieId: movieId,
            score: score,
            comment: comment,
            addToFavorites: addToFavorites,
          ),
        );
        created = record.rating;
      } else {
        created = await _ratingService.createRating(
          CreateRatingRequest(movieId: movieId, score: score, comment: comment),
        );
      }
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
      final code = apiErrorCode(error);
      closeDialogOnError = closingErrorCodes.contains(code);
      // 서버 message로 어떤 오류인지 알린다(예: 이미 이 영화를 즐겨찾기하셨습니다.)
      submitMessage = writeErrorMessage(error);
    } on StateError {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = '등록 결과를 확인하지 못했습니다.';
    } on FormatException {
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
