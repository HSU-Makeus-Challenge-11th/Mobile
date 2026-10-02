import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/models/movie_list_initial_data.dart';
import 'package:movielog/service/fake_movie_service.dart';
import 'package:movielog/service/genre_preference.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/genre_filter_chips.dart';
import 'package:movielog/widgets/genre_filter_sheet.dart';
import 'package:movielog/widgets/movie_grid_card.dart';
import 'package:movielog/widgets/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/movie_list_loading.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _allGenre = '전체';
  final _movieService = const FakeMovieService();
  final _genrePreference = GenrePreference();
  late Future<MovieListInitialData> _initialFuture;

  @override
  void initState() {
    super.initState();
    _initialFuture = _loadInitialData();
  }

  Future<MovieListInitialData> _loadInitialData() async {
    final results = await Future.wait([
      _movieService.fetchMovies().timeout(const Duration(seconds: 3)),
      _genrePreference.read(),
    ]);

    final data = MovieListInitialData(
      movies: results[0] as List<Movie>,
      selectedGenre: results[1] as String,
    );

    if (mounted) {
      setState(() => _applyGenre(data.selectedGenre));
    }

    return data;
  }

  /// 비어 있으면 전체 표시
  final Set<String> _selectedGenres = {};

  void _applyGenre(String genre) {
    _selectedGenres
      ..clear()
      ..addAll(genre == _allGenre ? <String>[] : [genre]);
  }

  List<Movie> _filter(List<Movie> movies) {
    if (_selectedGenres.isEmpty) return movies;
    return movies.where((m) => _selectedGenres.contains(m.genre)).toList();
  }

  List<String> get _genres => [
    ...{for (final movie in mockMovies) movie.genre},
  ];

  List<String> get _chipGenres => [_allGenre, ..._genres];

  /// Chip은 단일 선택만 표시한다
  String get _selectedChip {
    if (_selectedGenres.isEmpty) return _allGenre;
    if (_selectedGenres.length == 1) return _selectedGenres.first;
    return '';
  }

  void _onChipSelected(String genre) {
    setState(() => _applyGenre(genre));
    _genrePreference.save(genre);
  }

  void _retry() {
    setState(() {
      _initialFuture = _loadInitialData();
    });
  }

  Future<void> _refresh() async {
    final data = await _loadInitialData();
    if (!mounted) return;

    setState(() {
      _initialFuture = Future.value(data);
    });
  }

  Future<void> _openGenreFilter() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          GenreFilterSheet(genres: _genres, selectedGenres: _selectedGenres),
    );

    if (result == null) return;

    setState(() {
      _selectedGenres
        ..clear()
        ..addAll(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '영화',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violet,
                    ),
                  ),
                  IconButton(
                    onPressed: _openGenreFilter,
                    icon: const Icon(Icons.filter_list),
                    color: AppColors.violet,
                    tooltip: '장르 필터',
                  ),
                ],
              ),
            ),
            GenreFilterChips(
              genres: _chipGenres,
              selectedGenre: _selectedChip,
              onGenreSelected: _onChipSelected,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<MovieListInitialData>(
                future: _initialFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MovieListLoading();
                  }

                  if (snapshot.hasError) {
                    return MovieListError(onRetry: _retry);
                  }

                  final movies = _filter(
                    snapshot.data?.movies ?? const <Movie>[],
                  );

                  if (movies.isEmpty) {
                    return const MovieListEmpty();
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.55,
                          ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieGridCard(
                          movie: movie,
                          onTap: () => context.push('/movies/${movie.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
