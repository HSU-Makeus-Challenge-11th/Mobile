class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.duration,
    required this.synopsis,
  });
  final String id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final String duration;
  final String synopsis;
}
