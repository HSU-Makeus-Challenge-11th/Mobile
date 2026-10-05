import 'package:movielog/models/movie.dart';

const movies = <Movie>[
  Movie(
    id: 'starlight',
    title: '별빛 아래 우리',
    genre: '로맨스/드라마',
    year: 2024,
    posterAsset: 'assets/images/movie_starlight.png',
    rating: 4.8,
    duration: '124분',
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n\n별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.\n\n잔잔한 감동과 함께 삶의 의미를 다시 한번 되돌아보게 만드는 수작입니다.',
  ),
  Movie(
    id: 'space',
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/movie_space.png',
    rating: 4.2,
    duration: '118분',
    synopsis: '우주의 끝에서 보낸 마지막 신호가 낯선 행성의 문을 엽니다.',
  ),
  Movie(
    id: 'forest',
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    posterAsset: 'assets/images/movie_forest.png',
    rating: 4.9,
    duration: '109분',
    synopsis: '숲에 남겨진 기억을 따라 한 가족의 시간이 이어집니다.',
  ),
  Movie(
    id: 'shadow',
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/movie_shadow.png',
    rating: 3.8,
    duration: '105분',
    synopsis: '도시의 어두운 밤, 그림자를 쫓는 한 사람의 기록입니다.',
  ),
  Movie(
    id: 'coffee',
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    posterAsset: 'assets/images/movie_coffee.png',
    rating: 4.5,
    duration: '98분',
    synopsis: '봄날의 카페에서 시작된 우연한 만남이 일상이 됩니다.',
  ),
  Movie(
    id: 'city',
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    posterAsset: 'assets/images/movie_city.png',
    rating: 4.1,
    duration: '101분',
    synopsis: '도시의 선을 따라 서로 다른 꿈이 한 장면으로 이어집니다.',
  ),
];
const popularMovies = <Movie>[
  Movie(
    id: 'mars',
    title: '마션 레스큐',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/movie_mars.png',
    rating: 9.6,
    duration: '118분',
    synopsis: '화성에 홀로 남겨진 탐사대원이 지구로 돌아가기 위해 마지막 구조 신호를 보냅니다.',
  ),
  Movie(
    id: 'spy',
    title: '스파이 코드',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/movie_spy.png',
    rating: 9.2,
    duration: '110분',
    synopsis: '암호 속에 숨은 진실을 쫓는 요원의 긴박한 하루가 시작됩니다.',
  ),
  Movie(
    id: 'rain',
    title: '비오는 날의 기억',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/movie_rain.png',
    rating: 8.9,
    duration: '102분',
    synopsis: '비가 내리는 도시에서 오래된 기억과 마주한 사람들의 이야기입니다.',
  ),
];
const heroPosterAsset = 'assets/images/hero_starlight.png';
Movie? findMovieById(String id) {
  for (final movie in [...movies, ...popularMovies]) {
    if (movie.id == id) return movie;
  }
  return null;
}
