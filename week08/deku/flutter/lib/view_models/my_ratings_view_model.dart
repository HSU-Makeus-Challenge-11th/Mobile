import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/api_error_message.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'session_ratings_store.dart';

enum MyRatingsStatus { idle, loading, empty, error, success }

final class MyRatingItem {
  const MyRatingItem({required this.rating, required this.movie});

  final Rating rating;
  final TmdbMovieDto movie;
}

final class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._ratingApiService,
    this._movieService, {
    SessionRatingsStore? sessionStore,
    AuthViewModel? auth,
  }) : _sessionStore = sessionStore,
       _auth = auth;

  final RatingApiService _ratingApiService;
  final MovieService _movieService;
  final SessionRatingsStore? _sessionStore;
  final AuthViewModel? _auth;
  int? _memberId;
  bool _disposed = false;

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
    final version = _auth?.sessionVersion;
    status = MyRatingsStatus.loading;
    _notify();
    try {
      final ratings = _sessionStore != null
          ? _sessionStore.ratings
          : await _ratingApiService.fetchUserRatings(
              _memberId ?? (throw StateError('회원 ID가 필요합니다.')),
            );
      if (_disposed || !_isCurrent(version)) return;
      items = await Future.wait(ratings.map(_enrichRating));
      if (_disposed || !_isCurrent(version)) return;
      status = items.isEmpty ? MyRatingsStatus.empty : MyRatingsStatus.success;
    } catch (_) {
      if (_disposed || !_isCurrent(version)) return;
      status = MyRatingsStatus.error;
      items = const [];
    }
    _notify();
  }

  bool _isCurrent(int? version) =>
      version == null || (_auth?.isCurrentSession(version) ?? false);

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

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth?.sessionVersion;
    try {
      final updated = await _ratingApiService.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (!_isCurrent(version)) return;
      _sessionStore?.upsert(updated);
      await load();
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      message = apiErrorMessage(error);
      _notify();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _auth?.sessionVersion;
    try {
      await _ratingApiService.deleteRating(ratingId: ratingId);
      if (!_isCurrent(version)) return;
      _sessionStore?.remove(ratingId);
      await load();
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      message = apiErrorMessage(error);
      _notify();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
  }

  Future<int> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return 0;
    final version = _auth?.sessionVersion;
    isDeletingSelected = true;
    message = null;
    _notify();
    var failed = 0;
    try {
      for (final ratingId in selectedRatingIds.toList()) {
        if (!_isCurrent(version)) break;
        try {
          await _ratingApiService.deleteRating(ratingId: ratingId);
          if (!_isCurrent(version)) break;
          _sessionStore?.remove(ratingId);
          selectedRatingIds.remove(ratingId);
        } catch (_) {
          if (!_isCurrent(version)) break;
          failed++;
        }
      }
      if (_isCurrent(version)) await load();
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
