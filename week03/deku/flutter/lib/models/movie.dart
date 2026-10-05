class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.reviewCount,
    required this.synopsis,
    this.runtimeMinutes = 124,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final int reviewCount;
  final String synopsis;
  final int runtimeMinutes;
}
