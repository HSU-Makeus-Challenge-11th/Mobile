import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_page_footer.dart';

/// 영화 검색 화면(/movies/search). root Navigator 위에 열리므로 하단 NavigationBar가 없다.
///
/// 글자를 입력할 때마다 요청하지 않고 제출할 때만 TMDB Search를 요청한다.
/// 빈 검색어는 서버에 보내지 않고 입력 안내를 보여 준다.
/// 영화 목록 화면과는 별도의 PagedMoviesViewModel 인스턴스를 쓴다.
class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _text = TextEditingController();

  String _submittedQuery = '';
  String? _inputError;

  /// 새 검색은 항상 page 1부터 시작한다. 이전 결과는 ViewModel이 비운다.
  void _submitSearch(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() => _inputError = '검색어를 입력해 주세요.');
      return;
    }

    setState(() {
      _inputError = null;
      _submittedQuery = query;
    });
    FocusScope.of(context).unfocus();

    context.read<PagedMoviesViewModel>().loadInitial(query: query);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: AppColors.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '영화 검색',
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submitSearch,
                    decoration: InputDecoration(
                      labelText: '검색어',
                      errorText: _inputError,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '검색',
                  onPressed: () => _submitSearch(_text.text),
                  icon: const Icon(Icons.search),
                  color: AppColors.primary500,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PagedMoviesViewModel>(
              builder: (context, vm, _) {
                return switch (vm.phase) {
                  // 처음 진입한 상태(idle)와 결과가 없는 상태(empty)를 구분한다.
                  LoadPhase.idle => const EmptyView(message: '검색어를 입력해 주세요.'),
                  LoadPhase.loading => const LoadingView(),
                  LoadPhase.error => ErrorView(
                    message: vm.errorMessage ?? '검색 결과를 불러오지 못했습니다.',
                    onRetry: () => vm.loadInitial(query: _submittedQuery),
                  ),
                  LoadPhase.empty => const EmptyView(message: '검색 결과가 없습니다.'),
                  LoadPhase.ready => MovieGrid(
                    movies: vm.movies,
                    onTap: widget.onOpenMovie,
                    footer: MoviePageFooter(vm: vm),
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
