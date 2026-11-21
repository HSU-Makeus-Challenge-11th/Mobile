import 'package:movielog/data/models/favorite_response_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';

/// 즐겨찾기(MovieLog)와 영화 정보(TMDB)를 movieId로 합친 목록 카드 데이터
class FavoriteListItem {
  const FavoriteListItem({
    required this.favorite,
    this.movie,
    this.errorMessage,
    this.isRetrying = false,
  });

  final FavoriteResponseDto favorite;
  final TmdbMovieDto? movie;
  final String? errorMessage;
  final bool isRetrying;

  bool get hasMovie => movie != null;
}
