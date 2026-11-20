import 'package:movielog/data/models/favorite_response_dto.dart';
import 'package:movielog/data/models/rating_dto.dart';

/// POST /v8/movie-records 요청. addToFavorites는 필수 boolean이다
class CreateMovieRecordRequest {
  const CreateMovieRecordRequest({
    required this.movieId,
    required this.score,
    this.comment,
    required this.addToFavorites,
  });

  final int movieId;
  final int score;
  final String? comment;
  final bool addToFavorites;

  Map<String, dynamic> toJson() => {
    'movieId': movieId,
    'score': score,
    if (comment != null && comment!.trim().isNotEmpty)
      'comment': comment!.trim(),
    'addToFavorites': addToFavorites,
  };
}

/// 응답의 rating은 RatingDto, favorite은 FavoriteResponseDto를 그대로 쓴다.
/// addToFavorites가 false면 favorite은 null이다
class MovieRecordDto {
  const MovieRecordDto({required this.rating, this.favorite});

  factory MovieRecordDto.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('MovieRecordDto must be a JSON object.');
    }
    final favorite = json['favorite'];
    return MovieRecordDto(
      rating: RatingDto.fromJson(json['rating'] as Map<String, dynamic>),
      favorite: favorite == null
          ? null
          : FavoriteResponseDto.fromJson(favorite),
    );
  }

  final RatingDto rating;
  final FavoriteResponseDto? favorite;
}
