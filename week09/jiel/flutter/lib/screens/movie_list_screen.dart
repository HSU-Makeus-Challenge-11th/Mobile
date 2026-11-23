import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/load_phase.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_page_footer.dart';
import '../widgets/top_app_bar.dart';

/// 영화 목록 화면.
/// 9주차: 최대 30개 수집 대신 첫 page만 불러오고, 카드 목록 아래 footer의 "더 보기"로 한 page씩 붙인다.
/// 장르 칩 상태는 MovieListViewModel, 영화 목록·page 상태는 PagedMoviesViewModel이 가진다.
class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: TopAppBar(
        title: '영화',
        actions: [
          IconButton(
            tooltip: '영화 검색',
            onPressed: () => context.push('/movies/search'),
            icon: const Icon(Icons.search),
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 장르 필터 칩 (가로 ListView)
          const _GenreChipBar(),
          // 2. 영화 그리드 (2열) + 더 보기 footer
          Expanded(
            child: Consumer<PagedMoviesViewModel>(
              builder: (context, paged, child) {
                return switch (paged.phase) {
                  LoadPhase.idle || LoadPhase.loading => const LoadingView(),
                  LoadPhase.error => ErrorView(
                    message: paged.errorMessage ?? '영화를 불러오지 못했어요.',
                    onRetry: () {
                      // 장르 목록도 못 받았다면 함께 다시 불러온다.
                      context.read<MovieListViewModel>().loadGenres();
                      paged.reload();
                    },
                  ),
                  LoadPhase.empty => const EmptyView(
                    message: '해당 장르의 영화가 없어요.',
                  ),
                  LoadPhase.ready => MovieGrid(
                    movies: paged.movies,
                    genreNames: {
                      for (final genre
                          in context.watch<MovieListViewModel>().genres)
                        genre.id: genre.name,
                    },
                    onTap: (movie) =>
                        context.push('/movie/${movie.id}', extra: movie),
                    footer: MoviePageFooter(vm: paged),
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
                    // 장르를 바꾸면 이전 목록을 비우고 첫 page부터 다시 불러온다.
                    // 요청 중에 바꿔도 PagedMoviesViewModel이 generation으로 이전 장르의 늦은 응답을 버린다.
                    onTap: () {
                      if (viewModel.selectedGenreId == genreId) return;
                      viewModel.selectGenre(genreId);
                      context.read<PagedMoviesViewModel>().loadInitial(
                        genreId: genreId,
                      );
                    },
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
