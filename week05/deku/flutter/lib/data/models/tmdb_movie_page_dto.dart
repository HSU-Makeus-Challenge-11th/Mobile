import 'tmdb_movie_dto.dart';

final class TmdbMoviePageDto {
  const TmdbMoviePageDto({
    required this.page,
    required this.totalPages,
    required this.results,
  });

  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    return TmdbMoviePageDto(
      page: _asInt(json['page'], fallback: 1),
      totalPages: _asInt(json['total_pages'], fallback: 1),
      results: rawResults is List
          ? rawResults
                .whereType<Map>()
                .map(
                  (item) => TmdbMovieDto.fromJson(item.cast<String, dynamic>()),
                )
                .where((movie) => movie.id > 0)
                .toList(growable: false)
          : const [],
    );
  }

  final int page;
  final int totalPages;
  final List<TmdbMovieDto> results;
}

int _asInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
