class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.posterAsset,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final double rating;
  final String posterAsset;
}

const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2023,
    rating: 4.8,
    posterAsset: 'assets/images/posters/poster_us_under_the_starlight.jpg',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    rating: 4.2,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    rating: 4.9,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    rating: 3.8,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    rating: 4.5,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
  ),
  Movie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    rating: 4.1,
    posterAsset: 'assets/images/posters/poster_a_modern_architecture_flim_archive.jpg',
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}
