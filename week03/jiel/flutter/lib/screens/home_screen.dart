import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/top_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: TopAppBar(
        title: 'MovieLog',
      ),
      body: HomeScreenBody(),
    );
  }
}

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GreetingSection(),
            _FeaturedBanner(),
            _PopularMoviesSection(),
          ],
        ),
      ),
    );
  }
}

// 1. 인사 문구
class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        '오늘은 어떤\n영화를 볼까요?',
        style: TextStyle(
          fontSize: 28,
          height: 36 / 28,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.7,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

// 2. 추천 신작 배너
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 534,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/posters/hero_under_the_starlight.jpg',
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withValues(alpha: 0.7)),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary600.withValues(alpha: 0.9),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text(
                        '추천 신작',
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '별빛 아래 우리',
                      style: TextStyle(
                        fontSize: 28,
                        height: 36 / 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Opacity(
                      opacity: 0.9,
                      child: Text(
                        '로맨스 · 드라마 · 120분',
                        style: TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          color: Color(0xFFF8F2FA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        // 추천 신작 '별빛 아래 우리'(id: 1) 상세 화면
                        onPressed: () => context.push('/movie/1'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary600,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.info_outline, size: 17),
                        label: const Text(
                          '상세보기',
                          style: TextStyle(
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. 인기 영화 가로 리스트
class _Movie {
  const _Movie({
    required this.title,
    this.posterPath,
    this.rating,
    this.dDay,
  });

  final String title;
  final String? posterPath;
  final String? rating;
  final String? dDay;
}

const _popularMovies = [
  _Movie(
    title: '마션 레스큐',
    posterPath: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: '9.6',
  ),
  _Movie(
    title: '스파이 코드',
    posterPath: 'assets/images/posters/poster_spycode.jpg',
    rating: '9.2',
  ),
  _Movie(
    title: '비오는 날의 기억',
    posterPath: 'assets/images/posters/poster_the_shadow_tide.jpg',
    rating: '8.9',
  ),
  _Movie(title: '개봉 예정작', dDay: 'D-5'),
];

class _PopularMoviesSection extends StatelessWidget {
  const _PopularMoviesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '인기 영화',
                style: TextStyle(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Text(
                      '전체보기',
                      style: TextStyle(
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primary600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 272,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _popularMovies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                _MovieCard(movie: _popularMovies[index], rank: index + 1),
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, required this.rank});

  final _Movie movie;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final posterPath = movie.posterPath;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E0E9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: posterPath == null
                // 포스터가 없는 개봉 예정작
                ? Container(
                    color: const Color(0xFFECE6EE),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.movie_outlined,
                      size: 30,
                      color: AppColors.onSurfaceVariant,
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(posterPath, fit: BoxFit.cover),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _RankBadge(rank: rank),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (movie.rating != null)
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: AppColors.tertiary300),
                const SizedBox(width: 4),
                Text(
                  movie.rating!,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else if (movie.dDay != null)
            Text(
              movie.dDay!,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary600,
              ),
            ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$rank',
        style: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
