/// 즐겨찾기 등록(POST /v8/favorites)과 내 즐겨찾기 조회(GET /v8/favorites)의 항목입니다.
/// 제목·포스터는 없으므로 화면에 보여 줄 때는 movieId로 TMDB 정보를 따로 가져옵니다.
class FavoriteResponseDto {
  const FavoriteResponseDto({
    required this.favoriteId,
    required this.movieId,
    required this.createdAt,
  });

  factory FavoriteResponseDto.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('FavoriteResponseDto must be a JSON object.');
    }
    return FavoriteResponseDto(
      favoriteId: (json['favoriteId'] as num).toInt(),
      movieId: (json['movieId'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int favoriteId;
  final int movieId; // TMDB 영화 ID
  final DateTime createdAt;
}
