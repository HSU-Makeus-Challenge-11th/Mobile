import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/widgets/movies/movie_grid.dart';
import 'package:movielog/widgets/movies/movie_list_states.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  /// 상태별 화면 확인용: 디버그 모드에서 제목을 길게 누르면 불러오기 모드를 고른다
  Future<void> _pickDebugMode(BuildContext context) async {
    if (!kDebugMode) return;
    final viewModel = context.read<MovieListViewModel>();
    final mode = await showModalBottomSheet<MovieListDebugMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, label) in const [
              (MovieListDebugMode.normal, '정상'),
              (MovieListDebugMode.empty, '빈 목록'),
              (MovieListDebugMode.failure, '실패'),
            ])
              ListTile(
                title: Text(label),
                trailing: mode == viewModel.debugMode
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
    if (mode == null || !context.mounted) return;
    viewModel.changeDebugMode(mode);
  }

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
                  GestureDetector(
                    onLongPress: () => _pickDebugMode(context),
                    child: const Text(
                      '영화',
                      style: TextStyle(
                        fontSize: 22,
                        height: 28 / 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6750A4),
                      ),
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
            child: Consumer<MovieListViewModel>(
              builder: (context, viewModel, child) {
                return switch (viewModel.status) {
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading => const MovieListLoading(),
                  MovieListLoadStatus.error => MovieListError(
                    message: viewModel.message,
                    onRetry: () => context.read<MovieListViewModel>().retry(),
                  ),
                  MovieListLoadStatus.empty => const MovieListEmpty(),
                  MovieListLoadStatus.success => MovieGrid(
                    movies: viewModel.movies,
                    genreNames: viewModel.genreNames,
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
    final viewModel = context.watch<MovieListViewModel>();
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
              onPressed: viewModel.isLoading
                  ? null
                  : () => context.read<MovieListViewModel>().selectGenre(id),
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
