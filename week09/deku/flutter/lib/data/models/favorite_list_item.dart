import 'favorite.dart';
import 'tmdb_movie_dto.dart';

final class FavoriteListItem {
  const FavoriteListItem({required this.favorite, this.movie});

  final Favorite favorite;
  final TmdbMovieDto? movie;
  bool get movieLoadFailed => movie == null;
}
