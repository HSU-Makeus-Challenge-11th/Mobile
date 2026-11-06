import 'rating_dto.dart';
import 'tmdb_movie_dto.dart';

/// 자체 백엔드의 평점 한 건과, 그 movieId로 TMDB에서 찾은 영화 정보를 한 쌍으로 묶는다.
class RatingWithMovie {
  const RatingWithMovie({required this.rating, this.movie});

  final RatingDto rating;
  final TmdbMovieDto? movie; // TMDB에서 찾지 못했으면 null → 화면에서 placeholder
}
