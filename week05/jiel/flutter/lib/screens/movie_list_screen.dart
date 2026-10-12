import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_grid.dart';
import '../widgets/top_app_bar.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: const TopAppBar(title: '영화'),
      body: Column(
        children: [
          // 1. 장르 필터 칩 (가로 ListView)
          const _GenreChipBar(),
          // 2. 영화 그리드 (2열 GridView)
          Expanded(
            child: Consumer<MovieListViewModel>(
              builder: (context, viewModel, child) {
                return switch (viewModel.status) {
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading => const LoadingView(),
                  MovieListLoadStatus.error => ErrorView(
                    message: viewModel.message ?? '영화를 불러오지 못했어요.',
                    onRetry: () =>
                        context.read<MovieListViewModel>().loadInitial(),
                  ),
                  MovieListLoadStatus.empty => const EmptyView(
                    message: '해당 장르의 영화가 없어요.',
                  ),
                  MovieListLoadStatus.success => MovieGrid(
                    movies: viewModel.movies,
                    genreNames: {
                      for (final genre in viewModel.genres)
                        genre.id: genre.name,
                    },
                    onTap: (movie) => context.push('/movie/${movie.id}'),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChipBar extends StatelessWidget {
  const _GenreChipBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListViewModel>(
      builder: (context, viewModel, child) {
        // 첫 칩은 '전체'(id 없음), 이후는 TMDB 장르 목록
        final chips = <(int?, String)>[
          (null, '전체'),
          for (final genre in viewModel.genres) (genre.id, genre.name),
        ];

        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chips.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (genreId, label) = chips[index];
                return Center(
                  child: _GenreChip(
                    label: label,
                    selected: viewModel.selectedGenreId == genreId,
                    // 요청 중에는 null을 넘겨 칩을 비활성화한다.
                    onTap: viewModel.isLoading
                        ? null
                        : () => viewModel.selectGenre(genreId),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary500 : const Color(0xFFE6E0E9),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
