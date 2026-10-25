final class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    this.overview = '',
    this.posterPath,
    this.genreIds = const [],
    this.genreNames = const [],
    this.releaseDate,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.localPosterAsset,
  });

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    final rawGenreIds = json['genre_ids'];
    return TmdbMovieDto(
      id: _asInt(json['id']),
      title: json['title']?.toString().trim().isNotEmpty == true
          ? json['title'].toString().trim()
          : '제목 정보 없음',
      overview: json['overview']?.toString().trim() ?? '',
      posterPath: _nullableText(json['poster_path']),
      genreIds: rawGenreIds is List
          ? rawGenreIds
                .map(_asInt)
                .where((id) => id > 0)
                .toList(growable: false)
          : const [],
      releaseDate: _nullableText(json['release_date']),
      voteAverage: _asDouble(json['vote_average']),
      voteCount: _asInt(json['vote_count']),
    );
  }

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final List<int> genreIds;
  final List<String> genreNames;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;

  /// 테스트용 fixture가 기존 로컬 포스터를 재사용할 때만 사용합니다.
  final String? localPosterAsset;

  int? get releaseYear {
    final value = releaseDate;
    if (value == null || value.length < 4) return null;
    return int.tryParse(value.substring(0, 4));
  }

  String get genreLabel =>
      genreNames.isEmpty ? '장르 정보 없음' : genreNames.join(' · ');

  String get synopsis => overview.isEmpty ? '줄거리 정보가 없어요.' : overview;

  TmdbMovieDto copyWith({List<String>? genreNames}) {
    return TmdbMovieDto(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      genreIds: genreIds,
      genreNames: genreNames ?? this.genreNames,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      localPosterAsset: localPosterAsset,
    );
  }
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
