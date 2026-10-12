import 'package:flutter/material.dart';

import '../data/models/tmdb_movie_dto.dart';
import 'movie_card.dart';

/// 영화 목록을 2열 그리드로 보여준다.
class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    required this.onTap,
    this.genreNames = const {},
  });

  final List<TmdbMovieDto> movies;
  final ValueChanged<TmdbMovieDto> onTap;

  /// 장르 id → 이름. 카드에 첫 번째 장르 이름을 보여줄 때 쓴다.
  final Map<int, String> genreNames;

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
        final genreName = movie.genreIds.isEmpty
            ? null
            : genreNames[movie.genreIds.first];
        return MovieCard(
          movie: movie,
          genreName: genreName,
          onTap: () => onTap(movie),
        );
      },
    );
  }
}
