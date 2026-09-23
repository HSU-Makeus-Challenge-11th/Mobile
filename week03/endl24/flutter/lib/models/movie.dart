// lib/models/movie.dart
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
  });

  final String id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
}

final List<Movie> mockMovies = [
  const Movie(
    id: '1',
    title: '별빛 아래 우리',
    genre: '로맨스',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
  ),
  const Movie(
    id: '2',
    title: '심연을 걷는 자',
    genre: '스릴러',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
  ),
  const Movie(
    id: '3',
    title: '공허의 메아리',
    genre: 'SF',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
  ),
  const Movie(
    id: '4',
    title: '네 번째 오후',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
  ),
  const Movie(
    id: '5',
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2021,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
  ),
  const Movie(
    id: '6',
    title: '속삭이는 숲',
    genre: '로맨스',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
  ),
];

Movie? findMovieById(String id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}