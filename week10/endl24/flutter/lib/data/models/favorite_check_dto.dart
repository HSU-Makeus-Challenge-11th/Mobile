/// 특정 영화의 즐겨찾기 여부 조회(GET /v8/favorites/{movieId}) 결과입니다.
/// 응답에는 isFavorite만 있고 movieId가 없어서, 요청에 쓴 movieId를 따로 넘겨받습니다.
class FavoriteCheckDto {
  const FavoriteCheckDto({required this.movieId, required this.isFavorite});

  factory FavoriteCheckDto.fromJson(Object? json, {required int movieId}) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('FavoriteCheckDto must be a JSON object.');
    }
    final isFavorite = json['isFavorite'];
    if (isFavorite is! bool) {
      throw const FormatException('isFavorite must be a boolean.');
    }
    return FavoriteCheckDto(movieId: movieId, isFavorite: isFavorite);
  }

  final int movieId;
  final bool isFavorite;
}
