import 'package:flutter/foundation.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

/// 영화 목록 화면의 장르 칩 상태(장르 목록, 선택한 장르)만 관리한다.
///
/// 9주차: 5주차의 "Discover를 여러 번 호출해 최대 30개 수집" 방식은 PagedMoviesViewModel의
/// "더 보기" 방식으로 대체했다. 영화 목록·page 상태는 PagedMoviesViewModel이 가진다.
class MovieListViewModel extends ChangeNotifier with SafeNotify {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  bool _isLoadingGenres = false;

  /// 장르 목록을 불러온다. 실패해도 '전체' 칩만으로 목록을 볼 수 있게 오류로 올리지 않는다.
  Future<void> loadGenres() async {
    if (_isLoadingGenres || genres.isNotEmpty || isDisposed) return;
    _isLoadingGenres = true;
    try {
      final loaded = await _service.fetchGenres();
      if (isDisposed) return;
      genres = loaded;
    } catch (error) {
      debugPrint('장르 목록 로딩 실패: $error');
    } finally {
      _isLoadingGenres = false;
      notifyIfAlive();
    }
  }

  void selectGenre(int? genreId) {
    if (selectedGenreId == genreId) return;
    selectedGenreId = genreId;
    notifyIfAlive();
  }
}
