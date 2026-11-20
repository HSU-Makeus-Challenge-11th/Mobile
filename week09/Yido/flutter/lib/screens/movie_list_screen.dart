import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/core/debug/debug_faults.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
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
                  // 디버그 빌드에서 길게 누르면 다음 요청 하나를 실패시킬 수 있다
                  GestureDetector(
                    onLongPress: () => showDebugFaultSheet(context),
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
                  // W9: 오른쪽 "검색" 글자 버튼으로 검색 화면에 들어간다
                  GestureDetector(
                    key: const Key('openSearchButton'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/movies/search'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Text(
                        '검색',
                        style: w8Text(
                          13,
                          FontWeight.w700,
                          AppColors.primary500,
                        ).copyWith(height: 18 / 13),
                      ),
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
                  LoadPhase.ready => _InfiniteMovieGrid(viewModel: viewModel),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Challenge B: 끝에 가까워지면 다음 page를 자동으로 불러온다.
/// 실패하면 같은 page를 다시 시도하는 버튼을 보여 준다
class _InfiniteMovieGrid extends StatefulWidget {
  const _InfiniteMovieGrid({required this.viewModel});
  final PagedMoviesViewModel viewModel;

  @override
  State<_InfiniteMovieGrid> createState() => _InfiniteMovieGridState();
}

class _InfiniteMovieGridState extends State<_InfiniteMovieGrid> {
  /// 남은 스크롤 거리가 이 값 이하이면 다음 page를 요청한다
  static const loadThreshold = 300.0;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewport());
  }

  @override
  void didUpdateWidget(_InfiniteMovieGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewport());
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    if (_controller.position.extentAfter <= loadThreshold) _loadMore();
  }

  /// 첫 page가 화면을 다 채우지 못하면 스크롤할 수 없으므로 바로 이어서 불러온다
  void _fillViewport() {
    if (!mounted || !_controller.hasClients) return;
    if (_controller.position.maxScrollExtent <= 0) _loadMore();
  }

  void _loadMore() {
    final vm = widget.viewModel;
    // 실패한 뒤에는 자동으로 다시 요청하지 않고 버튼으로만 재시도한다
    if (vm.loadMoreError != null) return;
    vm.loadNextPage(); // 요청 중·마지막 page 중복 방지는 ViewModel이 맡는다
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MovieGrid(
    controller: _controller,
    movies: widget.viewModel.movies,
    genreNames: widget.viewModel.genreNames,
    footer: MoviePageFooter(vm: widget.viewModel, autoLoad: true),
  );
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
