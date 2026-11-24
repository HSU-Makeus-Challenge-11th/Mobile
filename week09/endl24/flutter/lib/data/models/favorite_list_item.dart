import 'package:movielog/data/models/favorite_response_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';

/// 내 즐겨찾기 화면의 카드 한 장입니다.
/// 서버 즐겨찾기(favorite)에 TMDB 영화 정보(movie)를 붙인 형태입니다.
/// TMDB 조회에 실패한 카드는 movie가 null이고 errorMessage가 있습니다.
class FavoriteListItem {
  const FavoriteListItem({
    required this.favorite,
    this.movie,
    this.errorMessage,
  });

  final FavoriteResponseDto favorite;
  final TmdbMovieDto? movie;
  final String? errorMessage;

  bool get hasMovie => movie != null;
}
