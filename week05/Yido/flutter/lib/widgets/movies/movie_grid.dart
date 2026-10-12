import 'package:flutter/material.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/widgets/movies/movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    this.genreNames = const {},
  });
  final List<TmdbMovieDto> movies;
  final Map<int, String> genreNames;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - 48) / 2;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: itemWidth / (itemWidth * 1.5 + 60),
        ),
        itemCount: movies.length,
        itemBuilder: (context, i) => MovieCard(
          movie: movies[i],
          genreNames: [for (final id in movies[i].genreIds) ?genreNames[id]],
        ),
      );
    },
  );
}
