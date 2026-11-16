import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/submit_status.dart';

export 'package:movielog/view_models/submit_status.dart';

/// 영화 상세 화면 ViewModel. 현재 화면의 영화 DTO와 **평점 등록** 상태만 관리한다.
/// 조회·수정·삭제는 마이페이지의 "내가 등록한 평점" 화면(MyRatingsViewModel)이 담당한다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this.memberId, this.movie);

  final RatingApiService _ratingService;

  /// 학습용 현재 회원(LearningMemberSession.memberId). 로그인 인증은 아니다.
  /// null이면 아직 회원가입을 하지 않은 상태라 등록 버튼을 비활성화한다.
  final int? memberId;

  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  bool get canRate => memberId != null;

  Future<void> createRating({required int score, String? comment}) async {
    final id = memberId;
    if (id == null) {
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 회원가입을 완료해 주세요.';
      notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return; // 연속 탭 방지
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      await _ratingService.createRating(
        memberId: id,
        request: CreateRatingRequest(
          movieId: movie.id, // 5주차 TmdbMovieDto.id
          score: score,
          comment: comment,
        ),
      );
      if (_disposed) return; // 화면 이탈 뒤에는 결과를 반영하지 않는다.
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      debugPrint('평점 등록 실패: ${error.response?.statusCode} ${error.response?.data}');
      submitStatus = SubmitStatus.error;
      // 400(별점 범위) / 404(없는 유저) / 409(이미 등록) 모두 서버 message를 그대로 보여준다.
      submitMessage = writeErrorMessage(error);
    } on StateError catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = error.message;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
