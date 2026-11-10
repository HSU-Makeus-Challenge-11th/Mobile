/// v6 평점 score는 1~5 사이의 **정수**다.
/// RatingBar는 항상 double을 돌려주므로, 위젯이 정수 단위로 막아 준 뒤에도
/// 서버로 보내기 직전 한 번 더 확인하는 안전장치로 남겨 둔다.
int validateServerScore(double value) {
  if (value < 1 || value > 5 || value != value.roundToDouble()) {
    throw ArgumentError('서버 평점은 1~5 사이 정수여야 합니다.');
  }
  return value.toInt();
}

/// POST /v6/members/{memberId}/ratings 요청 body.
class CreateRatingRequest {
  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  /// 5주차 TmdbMovieDto.id. 영화 배열 index나 임의 번호가 아니다.
  final int movieId;
  final int score;
  final String? comment;

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'score': score,
        // 등록 comment는 선택 항목이라 빈 문자열 대신 항목 자체를 생략한다.
        if (comment != null && comment!.trim().isNotEmpty)
          'comment': comment!.trim(),
      };
}
