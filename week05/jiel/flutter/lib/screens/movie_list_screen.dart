import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/genre_preferences.dart';
import '../data/mock/movie.dart';
import '../data/services/fake_movie_service.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/genre_filter_sheet.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_grid.dart';
import '../widgets/top_app_bar.dart';

const _allLabel = '전체';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final _movieService = const FakeMovieService();

  // 개발 중 Empty·Error 상태를 확인하기 위한 모드 (디버그 메뉴에서 변경)
  MovieLoadMode _loadMode = MovieLoadMode.success;
  late Future<List<Movie>> _moviesFuture;

  // 비어 있으면 '전체'. Chip과 BottomSheet가 같은 선택 상태를 공유한다.
  Set<String> _selectedGenres = {};

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.fetchMovies(mode: _loadMode);
    _restoreGenres();
  }

  // Future는 initState와 재시도에서만 새로 만든다.
  void _retry() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies(mode: _loadMode);
    });
  }

  void _changeLoadMode(MovieLoadMode mode) {
    _loadMode = mode;
    _retry();
  }

  Future<void> _restoreGenres() async {
    final saved = await loadSelectedGenres();
    if (!mounted) return;
    setState(() => _selectedGenres = saved);
  }

  void _setGenres(Set<String> next) {
    setState(() => _selectedGenres = next);
    saveSelectedGenres(next);
  }

  List<Movie> _filter(List<Movie> movies) => _selectedGenres.isEmpty
      ? movies
      : movies.where((movie) => _selectedGenres.contains(movie.genre)).toList();

  void _onChipTap(String label) {
    if (label == _allLabel) {
      _setGenres({});
      return;
    }
    // 이미 선택된 장르면 해제, 아니면 추가
    final next = {..._selectedGenres};
    if (!next.remove(label)) next.add(label);
    _setGenres(next);
  }

  Future<void> _openFilterSheet() async {
    final result = await showGenreFilterSheet(
      context,
      genres: genres,
      selected: _selectedGenres,
    );
    if (!mounted || result == null) return;
    _setGenres(result);
  }

  Widget _buildMovies(
    BuildContext context,
    AsyncSnapshot<List<Movie>> snapshot,
  ) {
    // 재시도 시 이전 error/data가 남아 있으므로 waiting을 가장 먼저 확인한다.
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      // 내부 예외는 로그에만 남기고 화면에는 고정 문구를 보여준다.
      debugPrint('영화 목록 로딩 실패: ${snapshot.error}');
      return ErrorView(message: '영화를 불러오지 못했어요.', onRetry: _retry);
    }

    final allMovies = snapshot.data ?? [];
    if (allMovies.isEmpty) return const EmptyView();

    final filteredMovies = _filter(allMovies);
    if (filteredMovies.isEmpty) {
      return const EmptyView(message: '해당 장르의 영화가 없어요.');
    }
    return MovieGrid(
      movies: filteredMovies,
      onTap: (movie) => context.push('/movie/${movie.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    const chipLabels = [_allLabel, ...genres];

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: TopAppBar(
        title: '영화',
        actions: [
          if (kDebugMode)
            PopupMenuButton<MovieLoadMode>(
              tooltip: '로딩 모드 (개발용)',
              icon: const Icon(Icons.bug_report_outlined),
              iconColor: AppColors.primary500,
              initialValue: _loadMode,
              onSelected: _changeLoadMode,
              itemBuilder: (context) => [
                for (final mode in MovieLoadMode.values)
                  PopupMenuItem(value: mode, child: Text(mode.name)),
              ],
            ),
          IconButton(
            onPressed: _openFilterSheet,
            tooltip: '장르 필터',
            icon: const Icon(Icons.filter_list),
            color: AppColors.primary500,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 장르 필터 칩 (가로 ListView)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: chipLabels.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = chipLabels[index];
                  final selected = label == _allLabel
                      ? _selectedGenres.isEmpty
                      : _selectedGenres.contains(label);
                  return Center(
                    child: _GenreChip(
                      label: label,
                      selected: selected,
                      onTap: () => _onChipTap(label),
                    ),
                  );
                },
              ),
            ),
          ),
          // 2. 영화 그리드 (2열 GridView)
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: _buildMovies,
            ),
          ),
        ],
      ),
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
