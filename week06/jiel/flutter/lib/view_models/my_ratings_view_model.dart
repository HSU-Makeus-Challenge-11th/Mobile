import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

/// 6주차 "내가 등록한 평점"의 조회 대상.
/// 로그인한 "내 계정"이 아니라 학습용 공개 데이터(memberId 1)다. 화면에 입력창을 두지 않고 상수로 관리한다.
/// (상태 확인용으로만 `--dart-define=MEMBER_ID=3` 처럼 실행 시 바꿀 수 있다. 기본값 1)
const int sampleMemberId = int.fromEnvironment('MEMBER_ID', defaultValue: 1);

/// Loading 화면을 캡처하기 위한 디버그 전용 지연(ms). 예: `--dart-define=RATINGS_DELAY_MS=3000`
const int _debugDelayMs = int.fromEnvironment('RATINGS_DELAY_MS');

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);
  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final int memberId;

  // 같은 movieId는 한 번만 조회한다. TMDB 404(영화 없음)는 null로 캐시한다.
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
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

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
