import 'package:flutter/foundation.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/service/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, success, empty, error }

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> popularMovies = const [];
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;

  bool _disposed = false; 

  Future<void> loadPopular() async {
    status = MovieHomeLoadStatus.loading;
    message = null; 
    notifyListeners();

    try {
      final page = await _service.fetchPopular();
      popularMovies = page.results.take(5).toList();
      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } catch (error) { 
      debugPrint('[MovieHomeViewModel] 인기 영화 로드 실패: $error');
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    }

    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}