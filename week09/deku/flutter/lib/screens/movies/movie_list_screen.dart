import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/tmdb_genre_dto.dart';
import '../../data/services/tmdb_movie_service.dart';
import '../../services/genre_preference.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/movie_list_view_model.dart';
import '../../view_models/paged_movies_view_model.dart';
import '../../widgets/movie_grid.dart';
import 'widgets/movie_list_empty.dart';
import 'widgets/movie_list_error.dart';
import 'widgets/movie_list_loading.dart';
import 'widgets/movie_page_footer.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({
    super.key,
    this.movieService,
    this.genrePreferenceStore,
  });

  static const routeName = '/movies';

  final MovieService? movieService;
  final GenrePreferenceStore? genrePreferenceStore;

  @override
  Widget build(BuildContext context) {
    final injectedService = movieService;
    if (injectedService != null) {
      return ChangeNotifierProvider(
        create: (_) => MovieListViewModel(
          injectedService,
          genrePreferenceStore ?? GenrePreference(),
        )..load(),
        child: const _MovieListView(),
      );
    }
    return const _MovieListView();
  }
}

class _MovieListView extends StatelessWidget {
  const _MovieListView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieListViewModel>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text(
          '영화',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '검색',
            onPressed: () => context.push('/movies/search'),
            icon: const Icon(Icons.search, size: 18),
          ),
          const SizedBox(width: AppSpacing.x1),
        ],
      ),
      body: Column(
        children: [
          _GenreChips(viewModel: viewModel),
          Expanded(
            child: switch (viewModel.status) {
              PageLoadStatus.idle ||
              PageLoadStatus.initialLoading => const MovieListLoading(),
              PageLoadStatus.empty => const MovieListEmpty(),
              PageLoadStatus.error => MovieListError(onRetry: viewModel.retry),
              PageLoadStatus.success => MovieGrid(
                movies: viewModel.movies,
                footer: MoviePageFooter(model: viewModel),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.viewModel});

  final MovieListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final choices = <TmdbGenreDto?>[null, ...viewModel.genres];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x2,
          AppSpacing.x1,
          AppSpacing.x2,
          AppSpacing.x1,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: choices.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.x1),
        itemBuilder: (context, index) {
          final genre = choices[index];
          final label = genre?.name ?? '전체';
          final isSelected = genre?.id == viewModel.selectedGenreId;
          return ChoiceChip(
            key: ValueKey('genre-filter-$label'),
            label: Text(label),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.secondary100,
            disabledColor: AppColors.secondary100,
            labelStyle: AppTextStyles.labelSmallMedium.copyWith(
              color: isSelected
                  ? AppColors.white
                  : AppColors.profileOnSurfaceVariant,
            ),
            side: BorderSide.none,
            onSelected: (_) => viewModel.selectGenre(genre?.id),
          );
        },
      ),
    );
  }
}
