final class Favorite {
  const Favorite({
    required this.favoriteId,
    required this.movieId,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    final favoriteId = _asInt(json['favoriteId']);
    final movieId = _asInt(json['movieId']);
    if (favoriteId == null || movieId == null || movieId < 1) {
      throw const FormatException('즐겨찾기 응답의 ID가 올바르지 않습니다.');
    }
    return Favorite(
      favoriteId: favoriteId,
      movieId: movieId,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  final int favoriteId;
  final int movieId;
  final DateTime? createdAt;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
