import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_ratings.dart';
import 'package:movielog/view_models/submit_status.dart';

/// 영화 상세 화면의 영화 정보와 평점 등록 상태를 관리합니다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._auth,
    this._sessionRatings,
    this.movie,
  );
  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final SessionRatings _sessionRatings;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return; // 연속 탭 방지
    final version = _auth.sessionVersion; // 요청을 보낸 세션을 기억합니다.
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      // memberId 없이 토큰만으로 등록합니다. result는 등록된 평점 객체입니다.
      final created = await _ratingService.createRating(
        CreateRatingRequest(
          movieId: movie.id, // 목록 순번이 아니라 TMDB 영화 id입니다.
          score: score,
          comment: comment,
        ),
      );
      // 화면이 닫혔어도 같은 세션이면 이번 세션 평점에는 넣어 둡니다.
      _sessionRatings.add(
        RatingWithMovie(rating: created, movie: movie),
        sessionVersion: version,
      );
      if (_disposed) return;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (version == _auth.sessionVersion &&
          isSessionInvalidCode(apiErrorCode(error))) {
        await _auth.expireSession(); // 401: 세션 정리 → Router가 /login으로 이동
      }
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(error); // 400·404·409 서버 문구 그대로
    } on StateError {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = '등록 결과를 확인하지 못했습니다. 잠시 후 다시 시도해 주세요.';
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
