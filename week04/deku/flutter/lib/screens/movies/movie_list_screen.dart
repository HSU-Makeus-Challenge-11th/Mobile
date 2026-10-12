import 'package:flutter/material.dart';

import '../../data/mock_movies.dart';
import '../../models/movie.dart';
import '../../services/genre_preference.dart';
import '../../services/movie_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/movie_grid.dart';
import 'widgets/movie_list_empty.dart';
import 'widgets/movie_list_error.dart';
import 'widgets/movie_list_loading.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    this.movieService,
    this.genrePreferenceStore,
  });

  static const routeName = '/movies';

  final MovieService? movieService;
  final GenrePreferenceStore? genrePreferenceStore;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late final MovieService _movieService;
  late final GenrePreferenceStore _genrePreferenceStore;
  late Future<List<Movie>> _moviesFuture;

  String _selectedGenre = GenrePreference.defaultGenre;

  @override
  void initState() {
    super.initState();
    _movieService = widget.movieService ?? FakeMovieService();
    _genrePreferenceStore = widget.genrePreferenceStore ?? GenrePreference();
    _moviesFuture = _restoreGenreAndFetchMovies();
  }

  Future<List<Movie>> _restoreGenreAndFetchMovies() async {
    final savedGenre = await _genrePreferenceStore.read();
    if (!mounted) return const <Movie>[];

    final availableGenres = <String>{
      GenrePreference.defaultGenre,
      ...movieGenres,
    };
    setState(() {
      _selectedGenre = availableGenres.contains(savedGenre)
          ? savedGenre
          : GenrePreference.defaultGenre;
    });

    return _fetchMovies();
  }

  Future<List<Movie>> _fetchMovies() {
    return _movieService.fetchMovies(genre: _selectedGenre);
  }

  Future<void> _selectGenre(String genre) async {
    if (genre == _selectedGenre) return;

    setState(() {
      _selectedGenre = genre;
      _moviesFuture = _fetchMovies();
    });

    await _genrePreferenceStore.save(genre);
  }

  void _retry() {
    setState(() {
      _moviesFuture = _fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final genres = ['전체', ...movieGenres];

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
            onPressed: () {},
            icon: const Icon(Icons.search, size: 18),
          ),
          const SizedBox(width: AppSpacing.x1),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2,
                AppSpacing.x1,
                AppSpacing.x2,
                AppSpacing.x1,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.x1),
              itemBuilder: (context, index) {
                final genre = genres[index];
                return ChoiceChip(
                  key: ValueKey('genre-filter-$genre'),
                  label: Text(genre),
                  selected: genre == _selectedGenre,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.secondary100,
                  labelStyle: AppTextStyles.labelSmallMedium.copyWith(
                    color: genre == _selectedGenre
                        ? AppColors.white
                        : AppColors.profileOnSurfaceVariant,
                  ),
                  side: BorderSide.none,
                  onSelected: (_) => _selectGenre(genre),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const MovieListLoading();
                }

                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                final loadedMovies = snapshot.data ?? const <Movie>[];
                if (loadedMovies.isEmpty) {
                  return const MovieListEmpty();
                }

                return MovieGrid(movies: loadedMovies);
              },
            ),
          ),
        ],
      ),
    );
  }
}
