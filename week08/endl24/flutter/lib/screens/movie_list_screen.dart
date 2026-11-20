import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/widgets/genre_filter_chips.dart';
import 'package:movielog/widgets/movie_grid_card.dart';
import 'package:movielog/widgets/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/movie_list_loading.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                '영화',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.violet,
                ),
              ),
            ),
            Expanded(
              child: Consumer<MovieListViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenreFilterChips(
                        genres: viewModel.genres,
                        selectedGenreId: viewModel.selectedGenreId,
                        enabled: !viewModel.isLoading,
                        onGenreSelected: (genreId) => context
                            .read<MovieListViewModel>()
                            .selectGenre(genreId),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildBody(context, viewModel)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MovieListViewModel viewModel) {
    return switch (viewModel.status) {
      MovieListLoadStatus.idle ||
      MovieListLoadStatus.loading => const MovieListLoading(),
      MovieListLoadStatus.error => MovieListError(
          message: viewModel.message,
          onRetry: () => context.read<MovieListViewModel>().loadInitial(),
        ),
      MovieListLoadStatus.empty => const MovieListEmpty(),
      MovieListLoadStatus.success => GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.55,
          ),
          itemCount: viewModel.movies.length,
          itemBuilder: (context, index) {
            final movie = viewModel.movies[index];
            return MovieGridCard(
              movie: movie,
              genreName: viewModel.genreNameOf(movie),
              onTap: () => context.push('/movies/${movie.id}', extra: movie),
            );
          },
        ),
    };
  }
}