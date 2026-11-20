import 'package:flutter/material.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';
import 'package:movielog/widgets/movies/movie_page_footer.dart';
import 'package:movielog/widgets/movies/movie_grid.dart';
import 'package:movielog/widgets/movies/movie_list_states.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '영화',
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF494551),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(height: 40, child: _GenreChips()),
          ),
          Expanded(
            child: Consumer<PagedMoviesViewModel>(
              builder: (context, viewModel, child) {
                return switch (viewModel.phase) {
                  LoadPhase.idle ||
                  LoadPhase.loading => const MovieListLoading(),
                  LoadPhase.error => MovieListError(
                    message: viewModel.errorMessage,
                    onRetry: viewModel.retryInitial,
                  ),
                  LoadPhase.empty => const MovieListEmpty(),
                  // 첫 page만 보여 주고, 아래 footer의 더 보기로 다음 page를 붙인다
                  LoadPhase.ready => MovieGrid(
                    movies: viewModel.movies,
                    genreNames: viewModel.genreNames,
                    footer: MoviePageFooter(vm: viewModel),
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

/// "전체" + Genre API로 받은 장르. 요청 중에는 눌러도 바뀌지 않는다
class _GenreChips extends StatelessWidget {
  const _GenreChips();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PagedMoviesViewModel>();
    final chips = <(int?, String)>[
      (null, '전체'),
      for (final genre in viewModel.genres) (genre.id, genre.name),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: chips.length,
      separatorBuilder: (context, index) => const SizedBox(width: 9),
      itemBuilder: (context, i) {
        final (id, name) = chips[i];
        final selected = viewModel.selectedGenreId == id;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 32,
            child: FilledButton(
              // 장르를 바꾸면 목록을 비우고 첫 page부터 다시 불러온다
              onPressed: viewModel.phase == LoadPhase.loading
                  ? null
                  : () => context.read<PagedMoviesViewModel>().loadInitial(
                      genreId: id,
                    ),
              style: FilledButton.styleFrom(
                backgroundColor: selected
                    ? const Color(0xFF6750A4)
                    : const Color(0xFFE6E0E9),
                foregroundColor: selected
                    ? Colors.white
                    : const Color(0xFF494551),
                disabledBackgroundColor: selected
                    ? const Color(0x996750A4)
                    : const Color(0x99E6E0E9),
                disabledForegroundColor: selected
                    ? Colors.white
                    : const Color(0x99494551),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: Size.zero,
              ),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
