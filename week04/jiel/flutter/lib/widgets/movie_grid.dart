import 'package:flutter/material.dart';

import '../data/mock/movie.dart';
import 'movie_card.dart';

/// 영화 목록을 2열 그리드로 보여준다.
class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies, required this.onTap});

  final List<Movie> movies;
  final ValueChanged<Movie> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 171 / 316.5,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(movie: movie, onTap: () => onTap(movie));
      },
    );
  }
}
