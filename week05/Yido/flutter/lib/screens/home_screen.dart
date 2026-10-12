import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE6E0E9)),
    ),
    child: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MovieLog',
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.55,
                      color: Color(0xFF4F378A),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF4F378A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 72,
                      child: Text(
                        '오늘은 어떤\n영화를 볼까요?',
                        style: TextStyle(
                          fontSize: 28,
                          height: 36 / 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.7,
                          color: Color(0xFF1D1B20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Consumer<MovieHomeViewModel>(
                      builder: (context, viewModel, child) =>
                          viewModel.status == MovieHomeLoadStatus.success
                          ? _Featured(movie: viewModel.popularMovies.first)
                          : const _FeaturedPlaceholder(),
                    ),
                  ),
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
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/movies'),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '전체보기',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4F378A),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 8,
                                color: Color(0xFF4F378A),
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
                    child: Consumer<MovieHomeViewModel>(
                      builder: (context, viewModel, child) {
                        final movies = viewModel.popularMovies;
                        return switch (viewModel.status) {
                          MovieHomeLoadStatus.idle ||
                          MovieHomeLoadStatus.loading => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          MovieHomeLoadStatus.error => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(viewModel.message ?? '인기 영화를 불러오지 못했어요.'),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () => context
                                      .read<MovieHomeViewModel>()
                                      .loadPopular(),
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          ),
                          MovieHomeLoadStatus.empty => const Center(
                            child: Text('인기 영화가 없습니다.'),
                          ),
                          // 인기 5개 뒤에 기존 개봉 예정작 카드를 붙인다
                          MovieHomeLoadStatus.success => ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: movies.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, i) => i == movies.length
                                ? const _ComingSoon()
                                : _PopularCard(movie: movies[i], rank: i + 1),
                          ),
                        };
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _openDetail(BuildContext context, TmdbMovieDto movie) =>
    context.push('/movies/${movie.id}', extra: MovieDetailArgs(movie: movie));

class _FeaturedPlaceholder extends StatelessWidget {
  const _FeaturedPlaceholder();
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 356,
    height: 534,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFECE6EE),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}

class _Featured extends StatelessWidget {
  const _Featured({required this.movie});
  final TmdbMovieDto movie;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _openDetail(context, movie),
    child: SizedBox(
      width: 356,
      height: 534,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            TmdbPosterImage(
              posterPath: movie.posterPath,
              width: 356,
              height: 534,
            ),
            const ColoredBox(color: Color(0xB3000000)),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 75,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xE64F378A),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '추천 신작',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: .6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 36 / 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.releaseYear ?? ''} · ★ ${movie.voteAverage.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 24 / 16,
                      color: Color(0xFFF8F2FA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _openDetail(context, movie),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F378A),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 17),
                      label: const Text(
                        '상세보기',
                        style: TextStyle(fontSize: 16, height: 24 / 16),
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

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.movie, required this.rank});
  final TmdbMovieDto movie;
  final int rank;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _openDetail(context, movie),
    child: SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TmdbPosterImage(
                  posterPath: movie.posterPath,
                  width: 140,
                  height: 200,
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  width: rank == 2
                      ? 26
                      : rank == 3
                      ? 25
                      : 24,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0x99000000),
                    border: Border.all(color: const Color(0x1AFFFFFF)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 16,
            child: Row(
              children: [
                const Icon(Icons.star, size: 11.67, color: Color(0xFFC9A74D)),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF494551),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 140,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFECE6EE),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                Icons.movie_outlined,
                size: 30,
                color: Color(0xFF494551),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          '개봉 예정작',
          style: TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'D-5',
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4F378A),
          ),
        ),
      ],
    ),
  );
}
