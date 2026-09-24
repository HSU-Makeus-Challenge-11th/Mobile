import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/genre_filter_chips.dart';
import 'package:movielog/widgets/movie_grid_card.dart';

const String _allGenres = '전체';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _selectedGenre = _allGenres;

  List<String> get _genres => [
    _allGenres,
    ...{for (final movie in mockMovies) movie.genre},
  ];

  List<Movie> get _filteredMovies {
    if (_selectedGenre == _allGenres) return mockMovies;
    return mockMovies
        .where((movie) => movie.genre == _selectedGenre)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filteredMovies;

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
            GenreFilterChips(
              genres: _genres,
              selectedGenre: _selectedGenre,
              onGenreSelected: (genre) {
                setState(() => _selectedGenre = genre);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: movies.isEmpty
                  ? const Center(child: Text('해당 장르의 영화가 없습니다.'))
                  : GridView.builder(
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
