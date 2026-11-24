import 'package:flutter/foundation.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/genre_preference.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';

/// 영화 목록 화면의 장르 필터 상태입니다.
///
/// 9주차부터 영화 자체는 PagedMoviesViewModel이 한 page씩 불러옵니다.
/// 이 ViewModel은 장르 목록, 선택한 장르(저장·복원), 카드에 표시할 장르 이름만 맡고
/// 장르가 바뀌면 PagedMoviesViewModel에 첫 page부터 다시 불러오라고 알립니다.
class MovieListViewModel extends ChangeNotifier with SafeNotify {
  MovieListViewModel(
    this._service,
    this._paged, {
    GenrePreference? genrePreference,
  }) : _genrePreference = genrePreference ?? GenrePreference();

  final TmdbMovieService _service;
  final PagedMoviesViewModel _paged;
  final GenrePreference _genrePreference;

  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;

  String? genreNameOf(TmdbMovieDto movie) {
    final selectedId = selectedGenreId;
    final genreId = selectedId != null && movie.genreIds.contains(selectedId)
        ? selectedId
        : movie.genreIds.firstOrNull;

    for (final genre in genres) {
      if (genre.id == genreId) return genre.name;
    }
    return null;
  }

  /// 저장해 둔 장르를 복원한 뒤, 장르 목록과 첫 page를 동시에 불러옵니다.
  Future<void> loadInitial() async {
    try {
      selectedGenreId ??= await _genrePreference.read();
    } catch (error) {
      debugPrint('[MovieListViewModel] 저장된 장르 읽기 실패: $error');
    }
    if (isDisposed) return;
    notifyIfAlive();

    _paged.loadInitial(genreId: selectedGenreId);
    await _loadGenres();
  }

  /// 장르 칩을 누르면 선택을 저장하고 첫 page부터 다시 불러옵니다.
  /// 이전 장르의 응답이 늦게 와도 PagedMoviesViewModel의 generation이 걸러 냅니다.
  void selectGenre(int? genreId) {
    if (genreId == selectedGenreId) return;
    selectedGenreId = genreId;
    _genrePreference.save(genreId);
    notifyIfAlive();
    _paged.loadInitial(genreId: genreId);
  }

  /// 장르 목록은 칩과 카드의 장르 이름에만 쓰여서, 실패해도 영화 목록은 그대로 보여 줍니다.
  Future<void> _loadGenres() async {
    try {
      final result = await _service.fetchGenres();
      if (isDisposed) return;
      genres = result;
      notifyIfAlive();
    } catch (error) {
      debugPrint('[MovieListViewModel] 장르 목록 로드 실패: $error');
    }
  }
}
