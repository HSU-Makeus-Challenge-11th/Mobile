/// v7 평점(Rating) 객체. 등록·수정 result와 공개 유저별 평점 조회 배열의 한 항목.
class RatingDto {
  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  final int ratingId;
  final int movieId; // TMDB 영화 ID
  final int score;
  final String? comment; // nullable: true → 값이 없을 수 있다
  final DateTime createdAt;

  factory RatingDto.fromJson(Map<String, dynamic> json) => RatingDto(
        ratingId: (json['ratingId'] as num).toInt(),
        movieId: (json['movieId'] as num).toInt(),
        score: (json['score'] as num).toInt(),
        comment: json['comment'] as String?,
        // createdAt이 빠진 응답이 와도 평점 자체를 버리지 않는다.
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
