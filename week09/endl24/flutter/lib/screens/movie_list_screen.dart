import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';
import 'package:movielog/widgets/genre_filter_chips.dart';
import 'package:movielog/widgets/movie_grid_card.dart';
import 'package:movielog/widgets/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/movie_list_loading.dart';
import 'package:movielog/widgets/movie_page_footer.dart';
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
            Consumer<MovieListViewModel>(
              builder: (context, filter, child) => GenreFilterChips(
                genres: filter.genres,
                selectedGenreId: filter.selectedGenreId,
                enabled: true, // 로딩 중에 바꿔도 이전 장르의 응답은 버려집니다.
                onGenreSelected: filter.selectGenre,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer2<PagedMoviesViewModel, MovieListViewModel>(
                builder: (context, paged, filter, child) =>
                    _buildBody(context, paged, filter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PagedMoviesViewModel paged,
    MovieListViewModel filter,
  ) {
    return switch (paged.phase) {
      LoadPhase.idle || LoadPhase.loading => const MovieListLoading(),
      LoadPhase.error => MovieListError(
        message: paged.errorMessage,
        onRetry: paged.retryInitial,
      ),
      LoadPhase.empty => const MovieListEmpty(),
      // 카드 grid 아래에 더 보기 footer를 붙이기 위해 CustomScrollView를 씁니다.
      LoadPhase.ready => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemCount: paged.movies.length,
              itemBuilder: (context, index) {
                final movie = paged.movies[index];
                return MovieGridCard(
                  movie: movie,
                  genreName: filter.genreNameOf(movie),
                  onTap: () =>
                      context.push('/movies/${movie.id}', extra: movie),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: MoviePageFooter(vm: paged)),
        ],
      ),
    };
  }
}
