import 'package:flutter/foundation.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/load_phase.dart';

/// 영화 목록과 검색 결과를 한 page씩 불러오는 ViewModel입니다.
/// 영화 목록 화면과 검색 화면이 각각 별도 인스턴스를 만들어 씁니다.
///
/// - 첫 page 성공: 목록을 교체합니다.
/// - 다음 page 성공: 이미 있는 movieId를 빼고 뒤에 붙인 뒤 nextPage를 올립니다.
/// - 다음 page 실패: 목록과 nextPage를 그대로 두어 같은 page를 다시 요청할 수 있습니다.
/// - 조건(장르·검색어) 변경: generation을 올리고 처음부터 다시 불러옵니다.
class PagedMoviesViewModel extends ChangeNotifier with SafeNotify {
  PagedMoviesViewModel({required this.tmdbApi});

  final TmdbMovieService tmdbApi;

  /// TMDB는 page를 1~500까지만 받습니다. total_pages가 더 커도 501은 요청하지 않습니다.
  static const maxTmdbPage = 500;

  LoadPhase phase = LoadPhase.idle;
  final List<TmdbMovieDto> movies = [];
  int nextPage = 1; // 다음에 요청할 page. 실패하면 그대로 둡니다.
  int totalPages = 1; // 서버 total_pages와 500 중 작은 값
  bool isLoadingMore = false;
  String? errorMessage; // 첫 page 실패 문구
  String? loadMoreError; // 다음 page 실패 문구(목록은 지우지 않습니다)

  bool get hasMore => nextPage <= totalPages;

  /// 조건이 바뀔 때마다 올려서, 이전 조건의 늦은 응답을 버립니다.
  int _requestGeneration = 0;
  ({int? genreId, String query}) _condition = (genreId: null, query: '');

  int? get genreId => _condition.genreId;
  String get query => _condition.query;

  /// 새 조건으로 첫 page부터 다시 불러옵니다. query가 있으면 검색, 없으면 장르 목록입니다.
  Future<void> loadInitial({int? genreId, String query = ''}) async {
    if (isDisposed) return;
    _condition = (genreId: genreId, query: query.trim());
    final condition = _condition;
    final generation = ++_requestGeneration;

    phase = LoadPhase.loading;
    errorMessage = null;
    loadMoreError = null;
    isLoadingMore = false;
    movies.clear();
    nextPage = 1;
    totalPages = 1;
    notifyIfAlive();

    try {
      final page = await _fetchPage(1, condition);
      if (_isStale(generation)) return;
      movies.addAll(_dedupe(page.results));
      _applyPageInfo(page);
      phase = movies.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (error) {
      if (_isStale(generation)) return;
      debugPrint('[PagedMoviesViewModel] 첫 page 실패: $error');
      phase = LoadPhase.error;
      errorMessage = condition.query.isEmpty
          ? '영화 목록을 불러오지 못했습니다.'
          : '검색 결과를 불러오지 못했습니다.';
    } finally {
      if (!_isStale(generation)) notifyIfAlive();
    }
  }

  /// 같은 조건으로 다시 불러옵니다(첫 page 오류의 다시 시도 버튼).
  Future<void> retryInitial() =>
      loadInitial(genreId: _condition.genreId, query: _condition.query);

  /// "더 보기". 요청 중이거나 마지막 page면 무시합니다.
  Future<void> loadNextPage() async {
    if (isDisposed || isLoadingMore || !hasMore || phase != LoadPhase.ready) {
      return;
    }
    final generation = _requestGeneration;
    final condition = _condition;
    final pageToLoad = nextPage;

    isLoadingMore = true;
    loadMoreError = null;
    notifyIfAlive();

    try {
      final page = await _fetchPage(pageToLoad, condition);
      if (_isStale(generation)) return;
      movies.addAll(_dedupe(page.results));
      _applyPageInfo(page);
    } catch (error) {
      if (_isStale(generation)) return;
      debugPrint('[PagedMoviesViewModel] $pageToLoad page 실패: $error');
      loadMoreError = '다음 페이지를 불러오지 못했습니다.';
    } finally {
      if (!_isStale(generation)) {
        isLoadingMore = false;
        notifyIfAlive();
      }
    }
  }

  bool _isStale(int generation) =>
      isDisposed || generation != _requestGeneration;

  Future<TmdbMoviePageDto> _fetchPage(
    int page,
    ({int? genreId, String query}) condition,
  ) async {
    final result = condition.query.isNotEmpty
        ? await tmdbApi.searchMovies(page: page, query: condition.query)
        : await tmdbApi.discoverMovies(page: page, genreId: condition.genreId);
    // 요청한 page와 응답 page가 다르면 nextPage가 꼬이므로 실패로 처리합니다.
    if (result.page != page || result.totalPages < 0) {
      throw const FormatException('TMDB page 정보가 요청과 맞지 않습니다.');
    }
    return result;
  }

  /// 성공한 page 기준으로만 nextPage를 올립니다.
  void _applyPageInfo(TmdbMoviePageDto page) {
    totalPages = page.totalPages > maxTmdbPage ? maxTmdbPage : page.totalPages;
    nextPage = page.page + 1;
  }

  /// TMDB는 인기순이 바뀌면 다음 page에 같은 영화를 다시 줄 수 있어 movieId로 걸러 냅니다.
  List<TmdbMovieDto> _dedupe(List<TmdbMovieDto> incoming) {
    final seen = movies.map((movie) => movie.id).toSet();
    return incoming.where((movie) => seen.add(movie.id)).toList();
  }
}
