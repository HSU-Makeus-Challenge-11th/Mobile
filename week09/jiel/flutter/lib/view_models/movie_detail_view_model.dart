import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/submit_status.dart';

export 'package:movielog/view_models/submit_status.dart';

/// 영화 상세 화면 ViewModel. 현재 화면의 영화 DTO와 **평점 등록** 상태만 관리한다.
/// 8주차: memberId 대신 로그인 토큰으로 등록한다(POST /v8/ratings).
/// 실제 요청과 세션별 평점 보관은 앱 최상단의 MyRatingsViewModel이 맡는다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratings, this.movie) {
    _ratings.addListener(_onRatingsChanged);
  }

  final MyRatingsViewModel _ratings;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  /// 이 세션에서 이 영화에 남긴 평점(등록 result의 Rating 객체). 현재 작업 카드에 표시한다.
  RatingDto? get myRating => _ratings.ratingForMovie(movie.id);

  void _onRatingsChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return; // 연속 탭 방지
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    final error = await _ratings.createRating(
      movie: movie, // 5주차 TmdbMovieDto.id가 movieId로 전송된다.
      score: score,
      comment: comment,
    );
    if (_disposed) return; // 화면 이탈 뒤에는 결과를 반영하지 않는다.
    submitStatus = error == null ? SubmitStatus.success : SubmitStatus.error;
    submitMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ratings.removeListener(_onRatingsChanged);
    super.dispose();
  }
}
