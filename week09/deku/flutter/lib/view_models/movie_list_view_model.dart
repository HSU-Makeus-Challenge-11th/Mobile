import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../services/genre_preference.dart';
import 'paged_movies_view_model.dart';

final class MovieListViewModel extends PagedMoviesViewModel {
  MovieListViewModel(super.service, this._preferenceStore);

  final GenrePreferenceStore _preferenceStore;
  List<TmdbGenreDto> genres = const [];

  Future<void> load() async {
    try {
      final savedGenreId = await _preferenceStore.read();
      genres = await service.fetchGenres();
      selectedGenreId = genres.any((genre) => genre.id == savedGenreId)
          ? savedGenreId
          : null;
      notifySafely();
    } catch (_) {
      genres = const [];
    }
    await loadFirst();
  }

  @override
  Future<void> selectGenre(int? genreId) async {
    if (selectedGenreId == genreId) return;
    final load = super.selectGenre(genreId);
    try {
      await _preferenceStore.save(genreId);
    } catch (_) {
      // A local setting failure must not block browsing.
    }
    await load;
  }

  Future<void> retry() => retryFirst();

  @override
  List<TmdbMovieDto> decorate(List<TmdbMovieDto> source) {
    final namesById = {for (final genre in genres) genre.id: genre.name};
    return source
        .map(
          (movie) => movie.copyWith(
            genreNames: movie.genreIds
                .map((id) => namesById[id])
                .whereType<String>()
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }
}
