final class TmdbGenreDto {
  const TmdbGenreDto({required this.id, required this.name});

  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) {
    return TmdbGenreDto(
      id: _asInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
    );
  }

  final int id;
  final String name;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
