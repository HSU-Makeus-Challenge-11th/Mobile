import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

/// Loading 화면을 캡처하기 위한 디버그 전용 지연(ms). 예: `--dart-define=RATINGS_DELAY_MS=3000`
const int _debugDelayMs = int.fromEnvironment('RATINGS_DELAY_MS');

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

/// "내가 등록한 평점" 화면의 조회·수정·삭제 ViewModel.
/// [memberId]는 6주차의 고정 1이 아니라 회원가입 결과를 보관한 LearningMemberSession에서 전달받는다.
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);
  final RatingApiService _service;
  final TmdbMovieService _movieService;

  /// 학습용 현재 회원. 로그인 인증은 아니며 앱을 재시작하면 다시 가입해야 한다.
  final int memberId;

  // 같은 movieId는 한 번만 조회한다. TMDB 404(영화 없음)는 null로 캐시한다.
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  /// 쓰기(수정·삭제)는 성공했지만 그 뒤 목록 GET만 실패했을 때의 안내.
  /// "저장 실패"와 "재조회 실패"를 구분하기 위해 message와 별도로 둔다.
  String? refreshWarning;

  /// 현재 진행 중인 쓰기 요청의 ratingId. Dialog가 열려 있는 동안 같은 카드의 중복 요청을 막는다.
  int? writingRatingId;

  bool get isWriting => writingRatingId != null;

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    refreshWarning = null;
    notifyListeners();

    bool isStale() => _disposed || version != _requestVersion;

    try {
      if (kDebugMode && _debugDelayMs > 0) {
        await Future<void>.delayed(const Duration(milliseconds: _debugDelayMs));
      }
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (isStale()) return;

      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      for (final rating in rawRatings) {
        if (isStale()) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] =
                await _movieService.findMovieById(rating.movieId);
          } on DioException catch (error) {
            // 일시적 네트워크 실패는 캐시하지 않는다(다음 로딩에서 재시도).
            // 영화 정보 실패가 평점 목록 자체를 지우지 않는다.
            debugPrint('TMDB 영화(${rating.movieId}) 조회 실패: ${error.message}');
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }
      if (isStale()) return;

      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (isStale()) return;
      debugPrint('평점 조회 실패: ${error.response?.statusCode} ${error.message}');
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    } catch (error) {
      // 응답 파싱 오류 등도 Error로 보내 로딩이 멈추지 않게 한다.
      if (isStale()) return;
      debugPrint('평점 응답 처리 실패: $error');
      status = MyRatingsLoadStatus.error;
      message = '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
    }

    if (!isStale()) notifyListeners();
  }

  /// 쓰기 성공 뒤 목록을 서버 상태와 맞춘다.
  /// GET 실패는 저장 실패가 아니므로 예외로 다시 던지지 않고 refreshWarning으로만 안내한다.
  Future<void> _refreshAfterWrite() async {
    await load(); // load()는 GET 실패를 status=error로 기록한다.
    if (_disposed) return;
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      message = refreshWarning;
      notifyListeners();
    } else {
      refreshWarning = null;
    }
  }

  /// PATCH /v6/members/{memberId}/ratings/{ratingId}
  /// score는 필수. comment를 생략하면 기존 후기가 null로 덮이므로 Dialog가 받은 값을 그대로 보낸다
  /// (유지하려면 기존 값, 지우려면 null).
  /// 쓰기 실패일 때만 rethrow해서 Dialog가 실패로 처리하고, 재조회 실패는 던지지 않는다.
  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    if (isWriting) return;
    writingRatingId = ratingId;
    notifyListeners();
    try {
      await _service.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
    } on DioException catch (error) {
      if (!_disposed) {
        // 400(별점 범위) / 403(본인 평점 아님) / 404(평점 없음)의 서버 message를 그대로 쓴다.
        message = writeErrorMessage(error);
        notifyListeners();
        // 403·404는 화면 목록이 서버와 어긋났다는 뜻이라 다시 조회한다.
        if (shouldRefreshAfterRatingError(error)) await load();
      }
      rethrow; // 쓰기 실패일 때만 Dialog가 실패로 처리한다.
    } finally {
      writingRatingId = null; // 예상하지 못한 오류(StateError 등)에도 잠금을 푼다.
    }
    if (_disposed) return;
    await _refreshAfterWrite(); // GET 실패는 저장 실패로 다시 던지지 않는다.
  }

  /// DELETE /v6/members/{memberId}/ratings/{ratingId}. 204는 body가 없어 파싱하지 않는다.
  Future<void> deleteRating(int ratingId) async {
    if (isWriting) return;
    writingRatingId = ratingId;
    notifyListeners();
    try {
      await _service.deleteRating(memberId: memberId, ratingId: ratingId);
    } on DioException catch (error) {
      if (!_disposed) {
        message = writeErrorMessage(error);
        notifyListeners();
        if (shouldRefreshAfterRatingError(error)) await load();
      }
      rethrow;
    } finally {
      writingRatingId = null;
    }
    if (_disposed) return;
    // 성공하면 곧바로 목록을 다시 읽는다. 마지막 항목을 지웠다면 load()가 empty 상태를 만든다.
    await _refreshAfterWrite();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
