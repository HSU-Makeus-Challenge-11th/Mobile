import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

/// 상태별 화면 확인용(디버그 모드 전용): 학습용 서버의 다른 회원을 조회한다
enum MyRatingsDebugMode {
  normal,
  empty(memberId: 3), // 평점이 없는 회원
  failure(memberId: 999999); // 존재하지 않는 회원

  const MyRatingsDebugMode({this.memberId});
  final int? memberId;
}

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);
  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final int memberId;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  /// 쓰기는 성공했는데 뒤이은 목록 조회만 실패했을 때의 안내
  String? refreshWarning;
  MyRatingsDebugMode debugMode = MyRatingsDebugMode.normal;

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    refreshWarning = null;
    notifyListeners();

    try {
      final rawRatings = await _service.fetchMyRatings(
        debugMode.memberId ?? memberId,
      );
      if (_disposed || version != _requestVersion) return;

      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      // 같은 movieId는 캐시를 사용하고, 영화 조회 실패가 평점 목록을 지우지 않는다
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] = await _movieService.findMovieById(
              rating.movieId,
            );
          } on DioException {
            // 일시적 네트워크 실패는 캐시하지 않고 다음 로딩에서 다시 시도한다
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }

      if (_disposed || version != _requestVersion) return;
      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  /// 다시 시도는 정상 모드로 현재 회원의 목록을 다시 조회한다
  Future<void> retry() {
    debugMode = MyRatingsDebugMode.normal;
    return load();
  }

  Future<void> _refreshAfterWrite() async {
    await load();
    if (!_disposed && status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      notifyListeners();
    }
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    try {
      await _service.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
    } on DioException catch (error) {
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow; // 쓰기 실패일 때만 Dialog가 실패로 처리한다
    }
    await _refreshAfterWrite(); // GET 실패는 저장 실패로 다시 던지지 않는다
  }

  Future<void> deleteRating(int ratingId) async {
    try {
      await _service.deleteRating(memberId: memberId, ratingId: ratingId);
    } on DioException catch (error) {
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> changeDebugMode(MyRatingsDebugMode mode) {
    debugMode = mode;
    return load();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
