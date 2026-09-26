// lib/models/movie.dart
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.ratingCount,
    required this.runtimeMinutes,
    required this.synopsis,
  });

  final String id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final int ratingCount;
  final int runtimeMinutes;
  final String synopsis;
}

final List<Movie> mockMovies = [
  const Movie(
    id: '1',
    title: '별빛 아래 우리',
    genre: '로맨스',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.5,
    ratingCount: 1245,
    runtimeMinutes: 124,
    synopsis: '바쁜 일상 속에서 서로의 존재를 잊고 살아가던 두 남녀가 '
        '우연한 계기로 작은 천문대에서 다시 만난다. 매일 밤 별을 관측하며 '
        '서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 이야기.',
  ),
  const Movie(
    id: '2',
    title: '심연을 걷는 자',
    genre: '스릴러',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.2,
    ratingCount: 982,
    runtimeMinutes: 118,
    synopsis: '탐사 도중 실종된 동료를 찾아 홀로 심연으로 내려간 잠수사. '
        '빛이 닿지 않는 어둠 속에서 그가 마주한 것은 동료의 흔적이 아니라 '
        '전혀 예상하지 못한 존재였다.',
  ),
  const Movie(
    id: '3',
    title: '공허의 메아리',
    genre: 'SF',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.9,
    ratingCount: 2038,
    runtimeMinutes: 142,
    synopsis: '지구와의 교신이 끊긴 우주정거장에 남겨진 대원이 '
        '알 수 없는 신호를 수신한다. 신호를 따라가던 그는 '
        '우주의 끝에서 자신과 똑같은 목소리를 듣게 된다.',
  ),
  const Movie(
    id: '4',
    title: '네 번째 오후',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.3,
    ratingCount: 756,
    runtimeMinutes: 106,
    synopsis: '매주 목요일 오후, 같은 카페 같은 자리에서 마주치는 두 사람. '
        '네 번째 오후가 되어서야 서로에게 건넨 짧은 인사가 '
        '두 사람의 계절을 완전히 바꿔놓는다.',
  ),
  const Movie(
    id: '5',
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2021,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    ratingCount: 1547,
    runtimeMinutes: 131,
    synopsis: '연쇄 실종 사건을 쫓던 형사가 도시의 뒷골목에서 '
        '20년 전 자신이 덮었던 사건의 그림자를 다시 마주한다. '
        '밤이 깊어질수록 진실은 그에게서 멀어진다.',
  ),
  const Movie(
    id: '6',
    title: '속삭이는 숲',
    genre: '로맨스',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.1,
    ratingCount: 634,
    runtimeMinutes: 97,
    synopsis: '할머니가 남긴 낡은 오두막으로 돌아온 소녀는 '
        '숲이 자신에게 말을 건다는 사실을 알게 된다. '
        '숲이 들려주는 이야기 속에는 가족이 숨겨온 오래된 약속이 담겨 있었다.',
  ),
];

Movie? findMovieById(String id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}