import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/api_error_message.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsStatus { idle, loading, empty, error, success }

final class MyRatingItem {
  const MyRatingItem({required this.rating, required this.movie});

  final Rating rating;
  final TmdbMovieDto movie;
}

final class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._ratingApiService, this._movieService);

  final RatingApiService _ratingApiService;
  final MovieService _movieService;
  int _memberId = 1; // 테스트 기본값. 앱 Route는 가입 결과를 반드시 전달합니다.
  bool _disposed = false;

  int get memberId => _memberId;
  MyRatingsStatus status = MyRatingsStatus.idle;
  List<MyRatingItem> items = const [];
  String? message;
  String? refreshWarning;
  bool isEditing = false;
  bool isDeletingSelected = false;
  final Set<int> selectedRatingIds = {};

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load({int? memberId}) async {
    if (memberId != null) _memberId = memberId;
    status = MyRatingsStatus.loading;
    _notify();
    try {
      final ratings = await _ratingApiService.fetchMyRatings(_memberId);
      if (_disposed) return;
      if (ratings.isEmpty) {
        items = const [];
        status = MyRatingsStatus.empty;
      } else {
        items = await Future.wait(ratings.map(_enrichRating));
        if (_disposed) return;
        status = MyRatingsStatus.success;
      }
    } catch (_) {
      if (_disposed) return;
      status = MyRatingsStatus.error;
      items = const [];
    }
    _notify();
  }

  Future<MyRatingItem> _enrichRating(Rating rating) async {
    try {
      final movie = await _movieService.fetchMovieById(rating.movieId);
      return MyRatingItem(rating: rating, movie: movie);
    } catch (_) {
      return MyRatingItem(
        rating: rating,
        movie: TmdbMovieDto(id: rating.movieId, title: '영화 #${rating.movieId}'),
      );
    }
  }

  void toggleEditing() {
    isEditing = !isEditing;
    if (!isEditing) selectedRatingIds.clear();
    _notify();
  }

  void toggleSelection(int ratingId) {
    if (!selectedRatingIds.add(ratingId)) selectedRatingIds.remove(ratingId);
    _notify();
  }

  Future<void> _refreshAfterWrite() async {
    await load();
    refreshWarning = status == MyRatingsStatus.error
        ? '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.'
        : null;
    if (status == MyRatingsStatus.empty) {
      isEditing = false;
      selectedRatingIds.clear();
    }
    _notify();
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    try {
      await _ratingApiService.updateRating(
        memberId: _memberId,
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
    } on DioException catch (error) {
      message = apiErrorMessage(error);
      _notify();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteRating(int ratingId) async {
    try {
      await _ratingApiService.deleteRating(
        memberId: _memberId,
        ratingId: ratingId,
      );
    } on DioException catch (error) {
      message = apiErrorMessage(error);
      _notify();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<int> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return 0;
    isDeletingSelected = true;
    message = null;
    _notify();
    var failed = 0;
    try {
      for (final ratingId in selectedRatingIds.toList()) {
        try {
          await _ratingApiService.deleteRating(
            memberId: _memberId,
            ratingId: ratingId,
          );
          selectedRatingIds.remove(ratingId);
        } catch (_) {
          failed++;
        }
      }
      await _refreshAfterWrite();
      if (failed > 0) {
        message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
      }
    } finally {
      isDeletingSelected = false;
      _notify();
    }
    return failed;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
