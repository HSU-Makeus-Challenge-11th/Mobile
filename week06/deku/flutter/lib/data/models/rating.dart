final class Rating {
  const Rating({
    required this.ratingId,
    required this.movieId,
    required this.score,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      ratingId: _asInt(json['ratingId']),
      movieId: _asInt(json['movieId']),
      score: _asInt(json['score']),
      comment: _nullableText(json['comment']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  final int ratingId;
  final int movieId;
  final int score;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayComment => comment ?? '후기 없음';

  String get displayCreatedAt {
    final date = createdAt;
    if (date == null) return '등록일 정보 없음';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _asDateTime(Object? value) {
  final text = _nullableText(value);
  return text == null ? null : DateTime.tryParse(text);
}
