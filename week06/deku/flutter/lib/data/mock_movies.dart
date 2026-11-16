import '../constants/app_assets.dart';
import 'models/tmdb_movie_dto.dart';

const movies = <TmdbMovieDto>[
  TmdbMovieDto(
    id: 1,
    title: '별빛 아래 우리',
    genreIds: [18, 10749],
    genreNames: ['드라마', '로맨스'],
    releaseDate: '2023-12-20',
    localPosterAsset: AppAssets.heroUnderTheStarlight,
    voteAverage: 9,
    voteCount: 1245,
    overview:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n\n별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.\n\n잔잔한 감동과 함께 삶의 의미를 다시 한번 되돌아보게 만드는 수작입니다.',
  ),
  TmdbMovieDto(
    id: 2,
    title: '우주의 끝에서',
    genreIds: [878],
    genreNames: ['SF'],
    releaseDate: '2024-03-08',
    localPosterAsset: AppAssets.posterEchoesOfTheVoid,
    voteAverage: 8.4,
    voteCount: 892,
    overview: '미지의 신호를 따라 우주의 끝으로 향한 탐사대가 마주한 선택과 우정을 그린 SF 드라마입니다.',
  ),
  TmdbMovieDto(
    id: 3,
    title: '기억의 숲',
    genreIds: [16],
    genreNames: ['애니메이션'],
    releaseDate: '2022-08-17',
    localPosterAsset: AppAssets.posterWhisperingWoods,
    voteAverage: 9.8,
    voteCount: 2081,
    overview: '잃어버린 기억을 찾아 신비로운 숲으로 들어간 아이의 아름다운 모험 이야기입니다.',
  ),
  TmdbMovieDto(
    id: 4,
    title: '밤의 그림자',
    genreIds: [53],
    genreNames: ['스릴러'],
    releaseDate: '2024-02-11',
    localPosterAsset: AppAssets.posterNightShadows,
    voteAverage: 7.6,
    voteCount: 645,
    overview: '도시의 밤마다 반복되는 사건을 추적하는 형사의 긴장감 넘치는 미스터리 스릴러입니다.',
  ),
  TmdbMovieDto(
    id: 5,
    title: '네 번째 오후',
    genreIds: [10749],
    genreNames: ['로맨스'],
    releaseDate: '2021-05-21',
    localPosterAsset: AppAssets.posterFourthAfternoon,
    voteAverage: 9,
    voteCount: 736,
    overview: '같은 카페, 같은 시간에 마주친 두 사람의 네 번의 오후를 담은 잔잔한 로맨스입니다.',
  ),
  TmdbMovieDto(
    id: 6,
    title: '심연의 보행자',
    genreIds: [878],
    genreNames: ['SF'],
    releaseDate: '2023-10-01',
    localPosterAsset: AppAssets.posterAbyssWalker,
    voteAverage: 9.6,
    voteCount: 1104,
    overview: '빛이 닿지 않는 심연에서 귀환한 탐사원이 들려주는 생존과 발견의 기록입니다.',
  ),
];

TmdbMovieDto? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}

List<String> get movieGenres =>
    <String>{for (final movie in movies) ...movie.genreNames}.toList();
