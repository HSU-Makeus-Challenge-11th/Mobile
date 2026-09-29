import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/genre_filter_chips.dart';
import 'package:movielog/widgets/genre_filter_sheet.dart';
import 'package:movielog/widgets/movie_grid_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _allGenre = '전체';

  /// 비어 있으면 전체 표시
  final Set<String> _selectedGenres = {};

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

  List<Movie> get _filteredMovies {
    if (_selectedGenres.isEmpty) return mockMovies;
    return mockMovies
        .where((movie) => _selectedGenres.contains(movie.genre))
        .toList();
  }

  void _onChipSelected(String genre) {
    setState(() {
      _selectedGenres
        ..clear()
        ..addAll(genre == _allGenre ? <String>[] : [genre]);
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
      builder: (context) => GenreFilterSheet(
        genres: _genres,
        selectedGenres: _selectedGenres,
      ),
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
    final movies = _filteredMovies;

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
              child: GridView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}