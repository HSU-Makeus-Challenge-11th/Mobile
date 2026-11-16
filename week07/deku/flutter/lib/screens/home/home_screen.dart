import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/tmdb_movie_dto.dart';
import '../../data/services/tmdb_movie_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/movie_home_view_model.dart';
import '../../widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.movieService});

  static const routeName = '/home';

  final MovieService? movieService;

  @override
  Widget build(BuildContext context) {
    final injectedService = movieService;
    if (injectedService != null) {
      return ChangeNotifierProvider(
        create: (_) => MovieHomeViewModel(injectedService)..load(),
        child: const _HomeView(),
      );
    }
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieHomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text('MovieLog'),
        titleTextStyle: AppTextStyles.profileAppBarTitle.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.55,
        ),
        actions: [
          IconButton(
            tooltip: '검색',
            onPressed: () {},
            icon: const Icon(Icons.search, size: 18),
          ),
          const SizedBox(width: AppSpacing.x1),
        ],
      ),
      body: switch (viewModel.status) {
        MovieHomeLoadStatus.idle || MovieHomeLoadStatus.loading => const Center(
          key: Key('home-movie-loading'),
          child: CircularProgressIndicator(),
        ),
        MovieHomeLoadStatus.empty => const Center(
          key: Key('home-movie-empty'),
          child: Text('인기 영화가 없어요.'),
        ),
        MovieHomeLoadStatus.error => Center(
          key: const Key('home-movie-error'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.x2),
              const Text('인기 영화를 불러오지 못했어요.'),
              const SizedBox(height: AppSpacing.x2),
              FilledButton.icon(
                key: const Key('home-movie-retry-button'),
                onPressed: viewModel.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        MovieHomeLoadStatus.success => _HomeSuccess(movies: viewModel.movies),
      },
    );
  }
}

class _HomeSuccess extends StatelessWidget {
  const _HomeSuccess({required this.movies});

  final List<TmdbMovieDto> movies;

  @override
  Widget build(BuildContext context) {
    final featuredMovie = movies.first;

    return SingleChildScrollView(
      key: const Key('home-scroll-view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 104,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.x2),
              child: Text(
                '오늘은 어떤\n영화를 볼까요?',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 28,
                  height: 36 / 28,
                  letterSpacing: -0.7,
                  fontWeight: FontWeight.w500,
                  color: AppColors.profileOnSurface,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              0,
              AppSpacing.x2,
              AppSpacing.x3,
            ),
            child: FeaturedMovieCard(movie: featuredMovie),
          ),
          SizedBox(
            height: 324,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '인기 영화',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 22,
                            height: 28 / 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.profileOnSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/movies'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('전체보기 ›'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 272,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.x2),
                    itemBuilder: (context, index) =>
                        PopularMovieCard(rank: index + 1, movie: movies[index]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class FeaturedMovieCard extends StatelessWidget {
  const FeaturedMovieCard({super.key, required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/movies/${movie.id}', extra: movie),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: SizedBox(
          key: const Key('featured-movie-banner'),
          height: 534,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TmdbPosterImage(movie: movie),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE6000000)],
                    stops: [0.38, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.x3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x1_5,
                        vertical: AppSpacing.x0_5,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary600,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        '인기 1위',
                        style: AppTextStyles.labelSmallMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLargeMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      [
                        if (movie.releaseYear != null) '${movie.releaseYear}',
                        movie.genreLabel,
                      ].join(' · '),
                      style: AppTextStyles.bodyLargeRegular.copyWith(
                        color: AppColors.surfaceHigh,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.push('/movies/${movie.id}', extra: movie),
                        icon: const Icon(Icons.info, size: 18),
                        label: const Text('상세보기'),
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

class PopularMovieCard extends StatelessWidget {
  const PopularMovieCard({super.key, required this.rank, required this.movie});

  final int rank;
  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/movies/${movie.id}', extra: movie),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: SizedBox(
                    width: 140,
                    height: 200,
                    child: TmdbPosterImage(movie: movie),
                  ),
                ),
                Positioned(
                  top: AppSpacing.x1,
                  left: AppSpacing.x1,
                  child: Container(
                    width: 24,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Text(
                      '$rank',
                      style: AppTextStyles.labelSmallBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x1_5),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLargeMedium,
            ),
            const SizedBox(height: AppSpacing.x0_5),
            Text(
              '★ ${movie.voteAverage.toStringAsFixed(1)}',
              style: AppTextStyles.labelSmallRegular.copyWith(
                color: AppColors.tertiary500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
