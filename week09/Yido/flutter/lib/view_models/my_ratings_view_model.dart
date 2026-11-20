import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

/// 이번 세션에 등록한 평점을 TMDB 영화 정보와 묶어 보여 주고, v8로 수정·삭제한다
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._store,
    this._auth,
  ) {
    _store.addListener(load);
  }
  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final SessionRatingStore _store;
  final AuthViewModel _auth;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_requestVersion;
    final source = _store.ratings;
    // 이미 화면에 있으면 영화 정보만 다시 맞추는 동안 목록을 비우지 않는다
    if (status != MyRatingsLoadStatus.success) {
      status = MyRatingsLoadStatus.loading;
    }
    message = null;
    notifyListeners();

    final entries = <RatingWithMovie>[];
    var missingMovies = 0;
    // 같은 movieId는 캐시를 쓰고, 영화 조회 실패가 평점을 지우지 않는다
    for (final rating in source) {
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
    notifyListeners();
  }

  Future<void> retry() => load();

  /// 쓰기 실패는 다시 던져 Dialog가 열린 채 문구를 보여 주게 한다
  Future<void> _handleWriteError(
    DioException error,
    int ratingId,
    int version,
  ) async {
    if (isSessionExpiredError(error) && version == _store.version) {
      await _auth.expireSession();
    } else if (isRatingGone(error)) {
      _store.remove(ratingId, version: version);
    }
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _store.version;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      _store.replace(updated, version: version);
    } on DioException catch (error) {
      await _handleWriteError(error, ratingId, version);
      rethrow;
    }
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _store.version;
    try {
      await _service.deleteRating(ratingId);
      _store.remove(ratingId, version: version);
    } on DioException catch (error) {
      await _handleWriteError(error, ratingId, version);
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _store.removeListener(load);
    super.dispose();
  }
}
