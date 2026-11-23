import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';

/// 8주차: "현재 로그인 세션에서 등록한 평점" 저장소(앱 최상단 Provider).
///
/// v7 로그인/내 정보 응답에는 memberId가 없고 토큰 기반 "내 평점 목록 GET"도 없다.
/// 그래서 7주차처럼 memberId로 목록을 다시 읽지 않고, 등록 response로 받은 Rating 객체를
/// 이 세션 안에서만 보관하고 v7 PATCH/DELETE로 변경한다.
/// 앱 재시작 뒤 기존 평점 전체 복원은 API 계약이 생기기 전까지 지원하지 않는다(README 참고).
///
/// 로그아웃·만료·회원 전환으로 signedIn이 아니게 되면 목록을 비운다.
/// 요청 전 sessionVersion을 기억해 두고, 응답이 왔을 때 세션이 바뀌었으면 결과를 버린다.
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._auth) {
    _auth.addListener(_onAuthChanged);
  }

  final RatingApiService _service;
  final AuthViewModel _auth;
  bool _disposed = false;

  /// movieId → TMDB 영화 정보. 평점 응답의 movieId(TMDB ID)로 제목·포스터를 찾는다.
  final Map<int, TmdbMovieDto> _moviesById = {};

  List<RatingDto> _ratings = const [];

  /// 현재 진행 중인 쓰기 요청의 ratingId(등록은 -1). 중복 요청을 막는다.
  int? writingRatingId;

  /// 마지막 쓰기 실패 문구(Dialog·Snackbar가 그대로 보여준다).
  String? message;

  bool get isWriting => writingRatingId != null;

  List<RatingWithMovie> get ratings => [
        for (final rating in _ratings)
          RatingWithMovie(rating: rating, movie: _moviesById[rating.movieId]),
      ];

  /// 이 세션에서 해당 영화에 남긴 평점(현재 작업 카드). 없으면 null.
  RatingDto? ratingForMovie(int movieId) {
    for (final rating in _ratings) {
      if (rating.movieId == movieId) return rating;
    }
    return null;
  }

  void _onAuthChanged() {
    if (_auth.status != AuthStatus.signedIn &&
        (_ratings.isNotEmpty || writingRatingId != null)) {
      _ratings = const [];
      writingRatingId = null;
      message = null;
      _notify();
    }
  }

  /// 공통 쓰기 실패 처리. 세션 만료면 세션을 정리하고, 그 외에는 안내 문구만 남긴다.
  /// 403·409는 로그인 상태를 유지한다.
  Future<String> _handleWriteError(DioException error, {int? ratingId}) async {
    final code = apiErrorCode(error);
    debugPrint('[Rating] 쓰기 실패: ${error.response?.statusCode} $code');
    if (isSessionExpiredCode(code)) {
      await _auth.expireSession(); // signedOut → Router가 /login으로 이동
      return '로그인이 만료됐어요. 다시 로그인해 주세요.';
    }
    if (code == 'RATING404_1' && ratingId != null) {
      // 서버에 없는 평점은 화면 목록에서도 정리한다.
      _ratings = _ratings.where((r) => r.ratingId != ratingId).toList();
    }
    return ratingErrorMessage(error);
  }

  /// POST /v8/ratings. 성공하면 null, 실패하면 안내 문구를 돌려준다.
  Future<String?> createRating({
    required TmdbMovieDto movie,
    required int score,
    String? comment,
  }) async {
    if (isWriting) return '이전 요청을 처리하고 있어요.';
    if (_auth.status != AuthStatus.signedIn) return '먼저 로그인해 주세요.';
    final version = _auth.sessionVersion;
    writingRatingId = -1;
    message = null;
    _notify();
    try {
      final created = await _service.createRating(
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      if (_isStale(version)) return null;
      _moviesById[created.movieId] = movie;
      _ratings = [created, ..._ratings.where((r) => r.ratingId != created.ratingId)];
      debugPrint('[Rating] 등록 성공 ratingId=${created.ratingId} movieId=${created.movieId}');
      return null;
    } on DioException catch (error) {
      if (_isStale(version)) return null;
      return message = await _handleWriteError(error);
    } catch (_) {
      if (_isStale(version)) return null;
      return message = '평점 응답을 처리하지 못했어요.';
    } finally {
      if (!_isStale(version)) {
        writingRatingId = null;
        _notify();
      }
    }
  }

  /// PATCH /v8/ratings/{ratingId}. score·comment를 함께 보낸다(전체 교체).
  Future<String?> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    if (isWriting) return '이전 요청을 처리하고 있어요.';
    final version = _auth.sessionVersion;
    writingRatingId = ratingId;
    message = null;
    _notify();
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_isStale(version)) return null;
      _ratings = [
        for (final r in _ratings) r.ratingId == ratingId ? updated : r,
      ];
      return null;
    } on DioException catch (error) {
      if (_isStale(version)) return null;
      return message = await _handleWriteError(error, ratingId: ratingId);
    } catch (_) {
      if (_isStale(version)) return null;
      return message = '평점 응답을 처리하지 못했어요.';
    } finally {
      if (!_isStale(version)) {
        writingRatingId = null;
        _notify();
      }
    }
  }

  /// DELETE /v8/ratings/{ratingId}. 성공은 200 + result null.
  Future<String?> deleteRating(int ratingId) async {
    if (isWriting) return '이전 요청을 처리하고 있어요.';
    final version = _auth.sessionVersion;
    writingRatingId = ratingId;
    message = null;
    _notify();
    try {
      await _service.deleteRating(ratingId);
      if (_isStale(version)) return null;
      _ratings = _ratings.where((r) => r.ratingId != ratingId).toList();
      return null;
    } on DioException catch (error) {
      if (_isStale(version)) return null;
      return message = await _handleWriteError(error, ratingId: ratingId);
    } catch (_) {
      if (_isStale(version)) return null;
      return message = '삭제 응답을 처리하지 못했어요.';
    } finally {
      if (!_isStale(version)) {
        writingRatingId = null;
        _notify();
      }
    }
  }

  bool _isStale(int version) =>
      _disposed ||
      version != _auth.sessionVersion ||
      _auth.status != AuthStatus.signedIn;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
