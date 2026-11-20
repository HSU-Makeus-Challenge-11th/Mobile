import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/favorites/movie_info_card.dart';
import 'package:movielog/widgets/favorites/w9_states.dart';
import 'package:movielog/widgets/movies/movie_page_footer.dart';
import 'package:movielog/widgets/w9_app_bar.dart';
import 'package:provider/provider.dart';

/// 영화 검색(W9). 제출할 때만 요청하고 빈 검색어는 서버에 보내지 않는다
class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({
    super.key,
    required this.onOpenMovie,
    this.onTitleLongPress,
  });

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;
  final VoidCallback? onTitleLongPress;

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _text = TextEditingController();
  String? _inputError;

  /// Challenge A: 입력이 500ms 멈추면 마지막 검색어로 한 번만 요청한다
  static const debounceDuration = Duration(milliseconds: 500);
  Timer? _debounce;
  String _lastQuery = '';

  void _onChanged(String value) {
    _debounce?.cancel(); // 입력할 때마다 이전 타이머를 취소한다
    _debounce = Timer(debounceDuration, () {
      if (!mounted) return;
      final query = value.trim();
      // 비어 있으면 서버에 보내지 않는다. 같은 검색어를 다시 요청하지도 않는다
      if (query.isEmpty || query == _lastQuery) return;
      _search(query);
    });
  }

  void _search(String query) {
    _lastQuery = query;
    setState(() => _inputError = null);
    // 늦게 도착한 이전 검색어의 응답은 PagedMoviesViewModel의 generation이 버린다
    context.read<PagedMoviesViewModel>().loadInitial(query: query);
  }

  static TextStyle _w9(double size, double line, FontWeight w, Color c) =>
      w8Text(size, w, c).copyWith(height: line / size);

  void _submit(String value) {
    _debounce?.cancel(); // 제출하면 기다리던 자동 검색은 보내지 않는다
    final query = value.trim();
    if (query.isEmpty) {
      setState(() => _inputError = '검색어를 입력해 주세요.');
      return;
    }
    // 새 검색은 이전 결과를 비우고 page 1부터 불러온다
    _search(query);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  Widget _searchBox() => Container(
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardBorder),
    ),
    padding: const EdgeInsets.only(left: 16, right: 13),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('searchField'),
            controller: _text,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _submit,
            style: _w9(15, 20, FontWeight.w400, AppColors.ink),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: '영화 제목',
              hintStyle: _w9(15, 20, FontWeight.w400, AppColors.inputText),
            ),
          ),
        ),
        GestureDetector(
          key: const Key('searchSubmitButton'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _submit(_text.text),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '검색',
              style: _w9(13, 18, FontWeight.w700, AppColors.primary500),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _results(PagedMoviesViewModel vm) => switch (vm.phase) {
    LoadPhase.idle => Center(
      child: Text(
        '보고 싶은 영화 제목을 검색해 보세요.',
        style: _w9(14, 19, FontWeight.w400, AppColors.mutedText),
      ),
    ),
    LoadPhase.loading => const Center(child: CircularProgressIndicator()),
    LoadPhase.error => W9ErrorState(
      message: vm.errorMessage ?? '검색 결과를 불러오지 못했습니다.',
      onRetry: vm.retryInitial,
    ),
    LoadPhase.empty => const SearchEmptyState(),
    LoadPhase.ready => ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
      itemCount: vm.movies.length + 1,
      separatorBuilder: (_, index) =>
          SizedBox(height: index == vm.movies.length - 1 ? 0 : 21),
      itemBuilder: (context, index) {
        if (index == vm.movies.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 25),
            child: MoviePageFooter(
              vm: vm,
              moreLabel: '검색 결과 더 보기',
              endLabel: '모든 검색 결과를 확인했습니다.',
            ),
          );
        }
        final movie = vm.movies[index];
        final year = movie.releaseYear;
        return MovieInfoCard(
          key: ValueKey('search_${movie.id}'),
          title: movie.title,
          subtitle: 'TMDB 영화 ID ${movie.id}',
          tag: year == null ? null : '$year 개봉',
          posterPath: movie.posterPath,
          onTap: () => widget.onOpenMovie(movie),
        );
      },
    ),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surfaceBright,
    appBar: W9AppBar(title: '영화 검색', onTitleLongPress: widget.onTitleLongPress),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: _searchBox(),
        ),
        if (_inputError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 24, 0),
            child: Text(
              _inputError!,
              key: const Key('searchInputError'),
              style: _w9(12, 16, FontWeight.w500, AppColors.error),
            ),
          ),
        Expanded(
          child: Consumer<PagedMoviesViewModel>(
            builder: (context, vm, _) => _results(vm),
          ),
        ),
      ],
    ),
  );
}
